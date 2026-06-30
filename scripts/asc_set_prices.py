#!/usr/bin/env python3
"""Set prices for Tre Voci's tip IAPs via the App Store Connect API.

For each product it finds the USA price point matching the target price, then
creates a price schedule with USA as the base territory (Apple auto-generates
equivalent prices in every other territory). Idempotent enough to re-run.

Auth: same ASC_ISSUER_ID / ASC_KEY_ID / ASC_P8 env as asc_create_iaps.py.
Usage: python3 scripts/asc_set_prices.py [--bundle com.trevoci-open.app] [--dry-run]
"""
import json, os, sys, time, argparse, urllib.request, urllib.error
try:
    import jwt
except ImportError:
    sys.exit("Missing dependency. Run: pip install pyjwt cryptography")

BASE = "https://api.appstoreconnect.apple.com"
# productId -> target customer price (USD)
TARGETS = {
    "com.trevoci.tip.small":  "0.99",
    "com.trevoci.tip.medium": "2.99",
    "com.trevoci.tip.large":  "5.99",
}

def token():
    iss, kid, p8 = os.environ.get("ASC_ISSUER_ID"), os.environ.get("ASC_KEY_ID"), os.environ.get("ASC_P8")
    if not (iss and kid and p8 and os.path.exists(p8)):
        sys.exit("Set ASC_ISSUER_ID, ASC_KEY_ID, ASC_P8.")
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

def usa_price_point(iap_id, target, tok):
    """Find the USA price point whose customerPrice equals (or is nearest) target."""
    path = f"/v2/inAppPurchases/{iap_id}/pricePoints?filter[territory]=USA&limit=200"
    best = None
    while path:
        page = api("GET", path, tok)
        for pp in page.get("data", []):
            cp = pp["attributes"].get("customerPrice", "")
            if cp == target:
                return pp["id"]
            try:
                d = abs(float(cp) - float(target))
                if best is None or d < best[0]:
                    best = (d, pp["id"], cp)
            except ValueError:
                pass
        path = page.get("links", {}).get("next")
    if best:
        print(f"     (exact {target} not found; nearest is {best[2]})")
        return best[1]
    return None

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bundle", default="com.trevoci-open.app")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    tok = token()

    apps = api("GET", f"/v1/apps?filter[bundleId]={args.bundle}", tok)["data"]
    if not apps:
        sys.exit(f"No app for {args.bundle}.")
    app_id = apps[0]["id"]
    iaps = {i["attributes"]["productId"]: i["id"]
            for i in api("GET", f"/v1/apps/{app_id}/inAppPurchasesV2?limit=200", tok).get("data", [])}

    for pid, price in TARGETS.items():
        iid = iaps.get(pid)
        if not iid:
            print(f"  ! {pid} not found (create it first)"); continue
        pp = usa_price_point(iid, price, tok)
        if not pp:
            print(f"  ! no USA price point for {pid}"); continue
        if args.dry_run:
            print(f"  + would set {pid} -> ${price} (pricePoint {pp})"); continue
        api("POST", "/v1/inAppPurchasePriceSchedules", tok, {
            "data": {"type": "inAppPurchasePriceSchedules",
                "relationships": {
                    "inAppPurchase": {"data": {"type": "inAppPurchases", "id": iid}},
                    "baseTerritory": {"data": {"type": "territories", "id": "USA"}},
                    "manualPrices": {"data": [{"type": "inAppPurchasePrices", "id": "${p}"}]}}},
            "included": [{"type": "inAppPurchasePrices", "id": "${p}",
                "attributes": {"startDate": None},
                "relationships": {"inAppPurchasePricePoint": {
                    "data": {"type": "inAppPurchasePricePoints", "id": pp}}}}]})
        print(f"  + {pid} -> ${price} set (USA base; auto-converts worldwide)")
    print("\nPrices set. Remaining manual per IAP: review screenshot + Submit for Review.")

if __name__ == "__main__":
    main()
