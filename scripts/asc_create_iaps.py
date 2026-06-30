#!/usr/bin/env python3
"""Create Tre Voci's 3 consumable tip IAPs via the App Store Connect API.

Creates each in-app purchase + its en-US localization, idempotently (skips any
productId that already exists). Does NOT set price, upload the review screenshot,
or submit for review — those are the manual steps (see the printout at the end).

Auth: needs an App Store Connect API key (Issuer ID + Key ID + .p8). Generate at
App Store Connect → Users and Access → Integrations → App Store Connect API.

Usage:
  pip install pyjwt cryptography            # one-time (or use the provided venv)
  export ASC_ISSUER_ID=...                  # the Issuer ID (UUID at top of Keys page)
  export ASC_KEY_ID=...                     # the Key ID of the key you generated
  export ASC_P8=/path/to/AuthKey_XXXX.p8    # the downloaded private key
  python3 scripts/asc_create_iaps.py [--bundle com.trevoci-open.app] [--dry-run]
"""
import json, os, sys, time, argparse, urllib.request, urllib.error

try:
    import jwt  # PyJWT
except ImportError:
    sys.exit("Missing dependency. Run: pip install pyjwt cryptography")

BASE = "https://api.appstoreconnect.apple.com"
TIPS = [
    ("com.trevoci.tip.small",  "Small thank-you",  "A small thank-you to the maker."),
    ("com.trevoci.tip.medium", "Medium thank-you", "A medium thank-you to the maker."),
    ("com.trevoci.tip.large",  "Large thank-you",  "A large thank-you to the maker."),
]
REVIEW_NOTE = "Optional tip to support the indie developer. Unlocks nothing; all content stays free."

def token():
    iss, kid, p8 = os.environ.get("ASC_ISSUER_ID"), os.environ.get("ASC_KEY_ID"), os.environ.get("ASC_P8")
    if not (iss and kid and p8 and os.path.exists(p8)):
        sys.exit("Set ASC_ISSUER_ID, ASC_KEY_ID, and ASC_P8 (path to the .p8 file).")
    now = int(time.time())
    return jwt.encode({"iss": iss, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
                      open(p8).read(), algorithm="ES256", headers={"kid": kid, "typ": "JWT"})

def api(method, path, tok, body=None):
    url = path if path.startswith("http") else BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method,
        headers={"Authorization": f"Bearer {tok}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read() or "{}")
    except urllib.error.HTTPError as e:
        sys.exit(f"API {method} {path} failed [{e.code}]: {e.read().decode()}")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bundle", default="com.trevoci-open.app")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    tok = token()

    apps = api("GET", f"/v1/apps?filter[bundleId]={args.bundle}", tok)["data"]
    if not apps:
        sys.exit(f"No app found for bundle {args.bundle}. Create the app record in App Store Connect first.")
    app_id = apps[0]["id"]
    print(f"App: {args.bundle} -> id {app_id}")

    existing = {i["attributes"]["productId"] for i in
                api("GET", f"/v1/apps/{app_id}/inAppPurchasesV2?limit=200", tok).get("data", [])}

    for pid, name, desc in TIPS:
        if pid in existing:
            print(f"  = {pid} already exists, skipping"); continue
        if args.dry_run:
            print(f"  + would create {pid} ('{name}')"); continue
        iap = api("POST", "/v2/inAppPurchases", tok, {"data": {"type": "inAppPurchases",
            "attributes": {"name": name, "productId": pid, "inAppPurchaseType": "CONSUMABLE", "reviewNote": REVIEW_NOTE},
            "relationships": {"app": {"data": {"type": "apps", "id": app_id}}}}})
        iid = iap["data"]["id"]
        api("POST", "/v1/inAppPurchaseLocalizations", tok, {"data": {"type": "inAppPurchaseLocalizations",
            "attributes": {"locale": "en-US", "name": name, "description": desc},
            "relationships": {"inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": iid}}}}})
        print(f"  + created {pid} ('{name}') -> {iid}")

    print("\nDONE creating products. STILL MANUAL in App Store Connect (per IAP):")
    print("  1. Set the price (Price Schedule).")
    print("  2. Upload a review screenshot (required to submit).")
    print("  3. Submit for review (reviews with your next app version).")
    print("Plus once, account-level: Agreements/Tax/Banking must be Active.")

if __name__ == "__main__":
    main()
