#!/usr/bin/env python3
"""Create an App Store provisioning profile via the ASC API and install it.
Needs an Admin ASC key (ASC_ISSUER_ID / ASC_KEY_ID / ASC_P8). Prints the profile name."""
import base64, json, os, sys, time, urllib.request, urllib.error
try:
    import jwt
except ImportError:
    sys.exit("pip install pyjwt cryptography")

BASE = "https://api.appstoreconnect.apple.com"
BUNDLE = sys.argv[1] if len(sys.argv) > 1 else "com.trevoci-open.app"
PROFILE_NAME = "TreVoci App Store (auto)"

def tok():
    now = int(time.time())
    return jwt.encode({"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 1200,
                       "aud": "appstoreconnect-v1"}, open(os.environ["ASC_P8"]).read(),
                      algorithm="ES256", headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"})

def api(method, path, t, body=None):
    req = urllib.request.Request(BASE + path, data=json.dumps(body).encode() if body else None,
        method=method, headers={"Authorization": f"Bearer {t}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read() or "{}")
    except urllib.error.HTTPError as e:
        sys.exit(f"{method} {path} [{e.code}]: {e.read().decode()}")

t = tok()
bids = api("GET", f"/v1/bundleIds?filter[identifier]={BUNDLE}", t)["data"]
if not bids:
    sys.exit(f"No bundleId record for {BUNDLE} in the developer portal.")
bid = bids[0]["id"]
certs = [c for c in api("GET", "/v1/certificates?limit=200", t)["data"]
         if c["attributes"]["certificateType"] in ("DISTRIBUTION", "IOS_DISTRIBUTION")]
if not certs:
    sys.exit("No distribution certificate found in the account.")
cert = certs[0]["id"]
print(f"bundleId={bid}  cert={cert} ({certs[0]['attributes'].get('name','')})")

# reuse an existing profile of this name if present, else create
existing = [p for p in api("GET", "/v1/profiles?limit=200", t)["data"]
            if p["attributes"]["name"] == PROFILE_NAME]
if existing:
    prof = api("GET", f"/v1/profiles/{existing[0]['id']}", t)["data"]
    print("reusing existing profile")
else:
    prof = api("POST", "/v1/profiles", t, {"data": {"type": "profiles",
        "attributes": {"name": PROFILE_NAME, "profileType": "IOS_APP_STORE"},
        "relationships": {"bundleId": {"data": {"type": "bundleIds", "id": bid}},
                          "certificates": {"data": [{"type": "certificates", "id": cert}]}}}})["data"]
    print("created profile")

content = base64.b64decode(prof["attributes"]["profileContent"])
dest = os.path.expanduser("~/Library/MobileDevice/Provisioning Profiles")
os.makedirs(dest, exist_ok=True)
uuid = prof["attributes"]["uuid"]
with open(f"{dest}/{uuid}.mobileprovision", "wb") as f:
    f.write(content)
print(f"installed {uuid}.mobileprovision")
print(f"PROFILE_NAME={PROFILE_NAME}")
