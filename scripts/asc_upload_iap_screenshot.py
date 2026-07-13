#!/usr/bin/env python3
"""Upload a review screenshot to Tre Voci's tip IAPs via the ASC API.

Apple requires one review screenshot per in-app purchase before it can be
submitted. This does the 3-step asset upload (reserve -> PUT bytes -> commit)
for each tip product. Pass an image (PNG/JPG) of the donation screen.

Auth: ASC_ISSUER_ID / ASC_KEY_ID / ASC_P8 env (Admin or App Manager key).
Usage: python3 scripts/asc_upload_iap_screenshot.py <image.png> [--bundle com.trevoci-open.app]
"""
import hashlib, json, os, sys, time, argparse, socket, urllib.request, urllib.error
socket.setdefaulttimeout(45)
try:
    import jwt
except ImportError:
    sys.exit("pip install pyjwt cryptography")

BASE = "https://api.appstoreconnect.apple.com"
PRODUCT_IDS = ["com.trevoci.tip.small", "com.trevoci.tip.medium", "com.trevoci.tip.large"]

def tok():
    now = int(time.time())
    return jwt.encode({"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 1200,
                       "aud": "appstoreconnect-v1"}, open(os.environ["ASC_P8"]).read(),
                      algorithm="ES256", headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"})

def api(method, path, t, body=None):
    # Raises urllib.error.HTTPError on failure (callers decide what to tolerate).
    req = urllib.request.Request(path if path.startswith("http") else BASE + path,
        data=json.dumps(body).encode() if body is not None else None, method=method,
        headers={"Authorization": f"Bearer {t}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read() or "{}")

def upload_one(iap_id, img, data, t):
    # 1. reserve
    res = api("POST", "/v1/inAppPurchaseAppStoreReviewScreenshots", t, {"data": {
        "type": "inAppPurchaseAppStoreReviewScreenshots",
        "attributes": {"fileName": os.path.basename(img), "fileSize": len(data)},
        "relationships": {"inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": iap_id}}}}})
    sid = res["data"]["id"]
    # 2. PUT bytes to each upload operation
    for op in res["data"]["attributes"]["uploadOperations"]:
        chunk = data[op["offset"]:op["offset"] + op["length"]]
        req = urllib.request.Request(op["url"], data=chunk, method=op["method"])
        for h in op["requestHeaders"]:
            req.add_header(h["name"], h["value"])
        urllib.request.urlopen(req).read()
    # 3. commit with checksum
    api("PATCH", f"/v1/inAppPurchaseAppStoreReviewScreenshots/{sid}", t, {"data": {
        "type": "inAppPurchaseAppStoreReviewScreenshots", "id": sid,
        "attributes": {"uploaded": True, "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
    return sid

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image")
    ap.add_argument("--bundle", default="com.trevoci-open.app")
    args = ap.parse_args()
    if not os.path.exists(args.image):
        sys.exit(f"image not found: {args.image}")
    data = open(args.image, "rb").read()
    t = tok()
    app_id = api("GET", f"/v1/apps?filter[bundleId]={args.bundle}", t)["data"][0]["id"]
    iaps = {i["attributes"]["productId"]: i["id"]
            for i in api("GET", f"/v1/apps/{app_id}/inAppPurchasesV2?limit=200", t)["data"]}
    for pid in PRODUCT_IDS:
        iid = iaps.get(pid)
        if not iid:
            print(f"  ! {pid} not found"); continue
        try:
            sid = upload_one(iid, args.image, data, t)
            print(f"  + {pid}: review screenshot uploaded ({sid})")
        except urllib.error.HTTPError as e:
            if e.code == 409:           # "Screenshot already exists" — this one's done
                print(f"  = {pid}: already has a review screenshot, skipping")
            else:
                print(f"  ! {pid}: [{e.code}] {e.read().decode()[:140]}"); raise
    print("\nDone. Each IAP now has a review screenshot. Remaining: Submit for Review (ASC UI).")

if __name__ == "__main__":
    main()
