#!/usr/bin/env python3
"""Re-check state and submit Tre Voci's tip IAPs for review via the ASC API.
Auth: ASC_ISSUER_ID / ASC_KEY_ID / ASC_P8. Usage: python3 scripts/asc_submit_iaps.py [--bundle ...]"""
import json, os, sys, time, socket, argparse, urllib.request, urllib.error
socket.setdefaulttimeout(40)
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

def api(method, path, t, body=None):
    req = urllib.request.Request(path if path.startswith("http") else BASE + path,
        data=json.dumps(body).encode() if body is not None else None, method=method,
        headers={"Authorization": f"Bearer {t}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read() or "{}")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bundle", default="com.trevoci-open.app")
    args = ap.parse_args()
    t = tok()
    app = api("GET", f"/v1/apps?filter[bundleId]={args.bundle}", t)["data"][0]["id"]
    iaps = api("GET", f"/v1/apps/{app}/inAppPurchasesV2?limit=50", t)["data"]
    for i in iaps:
        iid, a = i["id"], i["attributes"]
        pid, state = a["productId"], a.get("state")
        print(f"  {pid:24} state={state}")
        try:
            api("POST", "/v1/inAppPurchaseSubmissions", t, {"data": {
                "type": "inAppPurchaseSubmissions",
                "relationships": {"inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": iid}}}}})
            print(f"      -> SUBMITTED for review")
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            try:
                msg = json.loads(body)["errors"][0]
                print(f"      -> not submitted [{e.code}]: {msg.get('title')} — {msg.get('detail','')[:120]}")
            except Exception:
                print(f"      -> not submitted [{e.code}]: {body[:140]}")

if __name__ == "__main__":
    main()
