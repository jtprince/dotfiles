import pathlib
import requests

keypath = pathlib.Path.home() / "Dropbox/env/cloud-and-apis/slack/emoji-downloader"
token_path = keypath / "bot-oauth-token"

SLACK_TOKEN = token_path.read_text()

OUTPUT_DIR = pathlib.Path("slack_emojis")
OUTPUT_DIR.mkdir(exist_ok=True)

headers = {"Authorization": f"Bearer {SLACK_TOKEN}"}
response = requests.get("https://slack.com/api/emoji.list", headers=headers).json()

if not response.get("ok"):
    print(f"Error fetching emojis: {response.get('error')}")
    exit(1)

emojis = response.get("emoji", {})
print(f"Found {len(emojis)} custom emojis/aliases.")

for name, url in emojis.items():
    # Skip alias mappings (which point to another emoji name instead of a URL)
    if url.startswith("alias:"):
        continue

    ext = url.split(".")[-1].split("?")[0]
    filename = OUTPUT_DIR / f"{name}.{ext}"

    img_data = requests.get(url).content
    with open(filename, "wb") as f:
        f.write(img_data)
    print(f"Downloaded: {name}.{ext}")

print("Finished downloading all emojis!")
