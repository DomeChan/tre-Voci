#!/usr/bin/env python3
"""Submit the Tre Voci app version + its 3 tip IAPs for App Store review (one
review submission). Auth: ASC_ISSUER_ID / ASC_KEY_ID / ASC_P8.
Pass --submit to actually submit; without it, just creates the submission + adds items."""
import json, os, sys, time, socket, argparse, urllib.request, urllib.error
socket.setdefaulttimeout(50)
try:
    import jwt
except ImportError:
    sys.exit("pip install pyjwt cryptography")

BASE = "https://api.appstoreconnect.apple.com"

def tok():
    now = int(time.time())
    return jwt.encode({"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 1200,
                       "aud": "appstoreconnect-v1"}, open(os.environ["ASC_P8"]).read(),
                      algorithm="ES256", headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"})

def api(method, path, t, body=None, tolerate=()):
    req = urllib.request.Request(path if path.startswith("http") else BASE + path,
        data=json.dumps(body).encode() if body is not None else None, method=method,
        headers={"Authorization": f"Bearer {t}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read() or "{}")
    except urllib.error.HTTPError as e:
        if e.code in tolerate:
            return {"_e": e.code, "_b": e.read().decode()}
        body = e.read().decode()
        print(f"  ! {method} {path} [{e.code}]:")
        try:
            for err in json.loads(body).get("errors", []):
                print(f"      - {err.get('title')}: {err.get('detail','')}")
        except Exception:
            print("     ", body[:300])
        raise

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--submit", action="store_true"); args = ap.parse_args()
    t = tok()
    aid = api("GET", "/v1/apps?filter[bundleId]=com.trevoci-open.app", t)["data"][0]["id"]
    vid = api("GET", f"/v1/apps/{aid}/appStoreVersions?limit=1", t)["data"][0]["id"]
    iaps = [i["id"] for i in api("GET", f"/v1/apps/{aid}/inAppPurchasesV2?limit=50", t)["data"]]

    # reuse an in-progress submission if present, else create one
    subs = api("GET", f"/v1/apps/{aid}/reviewSubmissions?filter[state]=READY_FOR_REVIEW,UNRESOLVED_ISSUES,COMPLETING", t).get("data", [])
    if subs:
        sub = subs[0]["id"]; print(f"reusing review submission {sub} (state={subs[0]['attributes'].get('state')})")
    else:
        sub = api("POST", "/v1/reviewSubmissions", t, {"data": {"type": "reviewSubmissions",
            "attributes": {"platform": "IOS"},
            "relationships": {"app": {"data": {"type": "apps", "id": aid}}}}})["data"]["id"]
        print(f"created review submission {sub}")

    existing = {it.get("relationships", {}).get("appStoreVersion", {}).get("data", {}) and "version"
                for it in api("GET", f"/v1/reviewSubmissions/{sub}/items", t).get("data", [])}
    def add_item(rel, rid, label):
        r = api("POST", "/v1/reviewSubmissionItems", t, {"data": {"type": "reviewSubmissionItems",
            "relationships": {"reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub}},
                              rel: {"data": {"type": ("appStoreVersions" if rel == "appStoreVersion" else "inAppPurchases"), "id": rid}}}}},
            tolerate=(409,))
        print(f"  + item {label}: {'added' if '_e' not in r else 'already present'}")
    add_item("appStoreVersion", vid, "app version 0.1")
    for iid in iaps:
        add_item("inAppPurchaseV2", iid, f"IAP {iid}")

    if args.submit:
        api("PATCH", f"/v1/reviewSubmissions/{sub}", t, {"data": {"type": "reviewSubmissions",
            "id": sub, "attributes": {"submitted": True}}})
        st = api("GET", f"/v1/reviewSubmissions/{sub}", t)["data"]["attributes"].get("state")
        print(f"\nSUBMITTED. review submission state = {st}")
    else:
        print("\nItems staged (not submitted). Re-run with --submit to send to review.")

if __name__ == "__main__":
    main()
