#!/usr/bin/env python3
"""Create (or reuse) an App Store version, copy the en-US localization from the
previous version, and attach a build once it finishes processing.
Auth: ASC_ISSUER_ID / ASC_KEY_ID / ASC_P8."""
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
    ap = argparse.ArgumentParser()
    ap.add_argument("--bundle", default="com.trevoci-open.app")
    ap.add_argument("--version", required=True, help="e.g. 1.0")
    ap.add_argument("--build", help="build 'version' string to attach, e.g. 20260731 (waits for VALID processing)")
    ap.add_argument("--copy-from", help="appStoreVersion id to copy en-US localization from")
    args = ap.parse_args()
    t = tok()
    aid = api("GET", f"/v1/apps?filter[bundleId]={args.bundle}", t)["data"][0]["id"]

    versions = api("GET", f"/v1/apps/{aid}/appStoreVersions?limit=50", t)["data"]
    existing = [v for v in versions if v["attributes"].get("versionString") == args.version]
    if existing:
        vid = existing[0]["id"]
        print(f"reusing appStoreVersion {vid} ({args.version})")
    else:
        v = api("POST", "/v1/appStoreVersions", t, {"data": {"type": "appStoreVersions",
            "attributes": {"platform": "IOS", "versionString": args.version},
            "relationships": {"app": {"data": {"type": "apps", "id": aid}}}}})["data"]
        vid = v["id"]
        print(f"created appStoreVersion {vid} ({args.version})")

    if args.copy_from:
        src = api("GET", f"/v1/appStoreVersions/{args.copy_from}/appStoreVersionLocalizations", t)["data"]
        src_en = next((l for l in src if l["attributes"]["locale"] == "en-US"), None)
        dst = api("GET", f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations", t)["data"]
        if src_en and not dst:
            a = src_en["attributes"]
            api("POST", "/v1/appStoreVersionLocalizations", t, {"data": {"type": "appStoreVersionLocalizations",
                "attributes": {"locale": "en-US", "description": a.get("description"),
                                "keywords": a.get("keywords"), "marketingUrl": a.get("marketingUrl"),
                                "promotionalText": a.get("promotionalText"), "supportUrl": a.get("supportUrl"),
                                "whatsNew": "Tre Voci 1.0 — the first public release. Multilingual nursery rhymes "
                                            "(Italian, Mandarin, English, and more), audio-first playback, and an "
                                            "honest per-language listening view for parents."},
                "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": vid}}}}})
            print("  copied en-US localization (with a fresh What's New)")
        else:
            print("  localization already present or no source found, skipped")

    if args.build:
        aid2 = aid
        for attempt in range(30):
            builds = api("GET", f"/v1/apps/{aid2}/builds?filter[version]={args.build}&limit=1", t)["data"]
            if builds:
                b = builds[0]
                state = b["attributes"].get("processingState")
                print(f"  build {args.build}: processingState={state}")
                if state == "VALID":
                    api("PATCH", f"/v1/appStoreVersions/{vid}/relationships/build", t,
                        {"data": {"type": "builds", "id": b["id"]}})
                    print(f"  attached build {b['id']} to version {vid}")
                    break
                if state == "INVALID":
                    sys.exit("  build processing FAILED (INVALID) — check ASC for the reason")
            else:
                print(f"  build {args.build} not visible yet, waiting...")
            time.sleep(30)
        else:
            sys.exit("  timed out waiting for build to finish processing")

    print(f"\nVERSION_ID={vid}")

if __name__ == "__main__":
    main()
