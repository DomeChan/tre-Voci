#!/usr/bin/env python3
"""Upload App Store screenshots to the current version (en-US) via the ASC API.
Creates a screenshot set per display type and uploads each image (reserve->PUT->commit).
Auth: ASC_ISSUER_ID / ASC_KEY_ID / ASC_P8."""
import hashlib, json, os, sys, time, socket, urllib.request, urllib.error
socket.setdefaulttimeout(60)
try:
    import jwt
except ImportError:
    sys.exit("pip install pyjwt cryptography")

BASE = "https://api.appstoreconnect.apple.com"
SHOTS = "/private/tmp/claude-502/-Users-domenico-Documents-tre-Voci/3198419b-0ac4-4eea-8fe0-53b9d7615e5f/scratchpad/shots"
# display type -> ordered image files
SETS = {
    "APP_IPHONE_67": [f"{SHOTS}/iphone69/1-home.png", f"{SHOTS}/iphone69/2-donation.png"],
    "APP_IPAD_PRO_3GEN_129": [f"{SHOTS}/ipad13/1-home.png", f"{SHOTS}/ipad13/2-donation.png"],
}

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

def upload_shot(set_id, path, t):
    data = open(path, "rb").read()
    res = api("POST", "/v1/appScreenshots", t, {"data": {"type": "appScreenshots",
        "attributes": {"fileName": os.path.basename(path), "fileSize": len(data)},
        "relationships": {"appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}}}})
    sid = res["data"]["id"]
    for op in res["data"]["attributes"]["uploadOperations"]:
        chunk = data[op["offset"]:op["offset"] + op["length"]]
        req = urllib.request.Request(op["url"], data=chunk, method=op["method"])
        for h in op["requestHeaders"]:
            req.add_header(h["name"], h["value"])
        urllib.request.urlopen(req).read()
    api("PATCH", f"/v1/appScreenshots/{sid}", t, {"data": {"type": "appScreenshots", "id": sid,
        "attributes": {"uploaded": True, "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
    return sid

def main():
    t = tok()
    aid = api("GET", "/v1/apps?filter[bundleId]=com.trevoci-open.app", t)["data"][0]["id"]
    vid = api("GET", f"/v1/apps/{aid}/appStoreVersions?limit=1", t)["data"][0]["id"]
    vloc = [l for l in api("GET", f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations", t)["data"]
            if l["attributes"]["locale"] == "en-US"][0]["id"]
    existing = {s["attributes"]["screenshotDisplayType"]: s["id"]
                for s in api("GET", f"/v1/appStoreVersionLocalizations/{vloc}/appScreenshotSets", t).get("data", [])}
    for dtype, files in SETS.items():
        files = [f for f in files if os.path.exists(f)]
        if not files:
            print(f"  ! {dtype}: no files"); continue
        try:
            sid = existing.get(dtype) or api("POST", "/v1/appScreenshotSets", t, {"data": {
                "type": "appScreenshotSets", "attributes": {"screenshotDisplayType": dtype},
                "relationships": {"appStoreVersionLocalization": {"data": {"type": "appStoreVersionLocalizations", "id": vloc}}}}})["data"]["id"]
            n = len(api("GET", f"/v1/appScreenshotSets/{sid}/appScreenshots", t).get("data", []))
            for f in files:
                upload_shot(sid, f, t)
            print(f"  + {dtype}: {len(files)} screenshot(s) uploaded")
        except urllib.error.HTTPError as e:
            print(f"  ! {dtype}: [{e.code}] {e.read().decode()[:180]}")

if __name__ == "__main__":
    main()
