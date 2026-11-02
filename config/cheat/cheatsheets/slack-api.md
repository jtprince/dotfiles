# Slack Web API

Base URL: https://slack.com/api/<method>   (e.g. `chat.postMessage`)
Docs: https://api.slack.com/methods

## Tokens

| Prefix  | Kind        | Use                                                      |
| ------- | ----------- | -------------------------------------------------------- |
| `xoxb-` | bot         | most calls; acts as the app                              |
| `xoxp-` | user        | acts as you; needed for `search.messages`                |
| `xapp-` | app-level   | Socket Mode connections only                             |

```bash
export SLACK_BOT_TOKEN=xoxb-...
export SLACK_USER_TOKEN=xoxp-...
```

Scopes live at https://api.slack.com/apps -> your app -> OAuth & Permissions.
Reinstall the app after adding scopes. Common ones: `chat:write`,
`chat:write.public` (post without joining), `channels:read`, `groups:read`,
`channels:history`, `groups:history`, `im:history`, `users:read`,
`users:read.email`, `reactions:write`, `files:write`.

## Response rules

- HTTP status is 200 even on failure. Check `"ok": true|false` and `"error"`.
- `missing_scope` responses include `needed` and `provided`.
- 429 = rate limited. Wait `Retry-After` seconds.
- Paginate with `cursor` = `response_metadata.next_cursor` until it is `""`.
- Message IDs are `ts` strings (`"1730200000.123456"`). Keep them as strings.
- Reply in a thread by passing the parent's `ts` as `thread_ts`.

## httpie

`https` is httpie's https-by-default command. Plain `http slack.com/...` sends http://.

```bash
uv tool install httpie   # or: brew install httpie / pacman -S httpie  (-A bearer needs >= 3.0)

# auth check (who am I, which workspace)
https POST slack.com/api/auth.test -A bearer -a $SLACK_BOT_TOKEN

# same, explicit header
http POST https://slack.com/api/auth.test "Authorization:Bearer $SLACK_BOT_TOKEN"

# alias to save typing
alias slk='https -A bearer -a $SLACK_BOT_TOKEN'
```

Write methods take JSON (httpie's default). Read methods: use query params (`==`)
or form (`-f`); several of them ignore JSON bodies.

```bash
# post a message (channel name or ID)
slk POST slack.com/api/chat.postMessage channel=C0123456789 text='hello *bold* <https://x.com|link>'

# reply in a thread
slk POST slack.com/api/chat.postMessage channel=C0123456789 thread_ts=1730200000.123456 text='reply'

# Block Kit (raw JSON with :=)
slk POST slack.com/api/chat.postMessage channel=C0123456789 text='fallback' \
  blocks:='[{"type":"section","text":{"type":"mrkdwn","text":"*Title*\nbody"}}]'

# whole payload from a file
slk POST slack.com/api/chat.postMessage < msg.json

# edit / delete
slk POST slack.com/api/chat.update channel=C0123456789 ts=1730200000.123456 text='edited'
slk POST slack.com/api/chat.delete channel=C0123456789 ts=1730200000.123456

# react
slk POST slack.com/api/reactions.add channel=C0123456789 timestamp=1730200000.123456 name=thumbsup

# permalink for a message
slk GET slack.com/api/chat.getPermalink channel==C0123456789 message_ts==1730200000.123456
```

```bash
# find a channel ID by name
slk GET slack.com/api/conversations.list types==public_channel,private_channel limit==1000 \
  | jq -r '.channels[] | select(.name=="general") | .id'

# recent history
slk GET slack.com/api/conversations.history channel==C0123456789 limit==50 \
  | jq -r '.messages[] | "\(.ts)  \(.user)  \(.text)"'

# history in a time window (unix seconds)
slk GET slack.com/api/conversations.history channel==C0123456789 \
  oldest==$(date -d '7 days ago' +%s) latest==$(date +%s)   # macOS: date -v-7d +%s

# thread replies
slk GET slack.com/api/conversations.replies channel==C0123456789 ts==1730200000.123456

# user lookup
slk GET slack.com/api/users.lookupByEmail email==someone@example.com | jq '.user | {id, name, real_name}'
slk GET slack.com/api/users.info user==U0123456789

# search (user token only)
https GET slack.com/api/search.messages -A bearer -a $SLACK_USER_TOKEN query=='from:@me in:#general budget' count==20
```

Pagination loop:

```bash
cursor=""
while :; do
  r=$(slk GET slack.com/api/conversations.list limit==200 cursor==$cursor)
  echo "$r" | jq -r '.channels[] | "\(.id)\t\(.name)"'
  cursor=$(echo "$r" | jq -r '.response_metadata.next_cursor // ""')
  [ -z "$cursor" ] && break
done
```

Incoming webhook (no token, fixed channel):

```bash
http POST https://hooks.slack.com/services/T000/B000/XXXX text='deploy finished'
```

## Python (slack_sdk)

```bash
uv add slack_sdk          # or: uv pip install slack_sdk
```

```python
import os
from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError

client = WebClient(token=os.environ["SLACK_BOT_TOKEN"])
client.auth_test()  # raises SlackApiError if the token is bad

try:
    resp = client.chat_postMessage(channel="C0123456789", text="hello")
    ts = resp["ts"]
    client.chat_postMessage(channel="C0123456789", thread_ts=ts, text="threaded reply")
except SlackApiError as e:
    print(e.response["error"])  # e.g. not_in_channel, channel_not_found, missing_scope
```

Method names map `chat.postMessage` -> `chat_postMessage`. Any method without
a wrapper: `client.api_call("team.info", params={...})`.

```python
# Block Kit
client.chat_postMessage(
    channel="C0123456789",
    text="fallback for notifications",
    blocks=[
        {"type": "section", "text": {"type": "mrkdwn", "text": "*Title*\nbody"}},
        {"type": "divider"},
        {"type": "context", "elements": [{"type": "mrkdwn", "text": "posted by bot"}]},
    ],
)

# edit / delete / react
client.chat_update(channel=ch, ts=ts, text="edited")
client.chat_delete(channel=ch, ts=ts)
client.reactions_add(channel=ch, timestamp=ts, name="thumbsup")

# schedule (post_at = unix seconds)
client.chat_scheduleMessage(channel=ch, post_at=int(time.time()) + 3600, text="later")
```

Pagination: a `SlackResponse` iterates over pages and follows the cursor.

```python
messages = []
for page in client.conversations_history(channel="C0123456789", limit=200):
    messages.extend(page["messages"])

channels = {
    c["name"]: c["id"]
    for page in client.conversations_list(types="public_channel,private_channel", limit=200)
    for c in page["channels"]
}
```

Automatic retry on 429:

```python
from slack_sdk.http_retry.builtin_handlers import RateLimitErrorRetryHandler

client.retry_handlers.append(RateLimitErrorRetryHandler(max_retry_count=3))
```

Users:

```python
user = client.users_lookupByEmail(email="someone@example.com")["user"]
user["id"], user["real_name"], user["profile"]["display_name"]
```

File upload (`files.upload` is retired; `files_upload_v2` wraps the
`getUploadURLExternal` / `completeUploadExternal` flow):

```python
client.files_upload_v2(
    channel="C0123456789",          # must be an ID, not a name
    file="report.pdf",
    title="Weekly report",
    initial_comment="here it is",
)
```

Webhook:

```python
from slack_sdk.webhook import WebhookClient

WebhookClient(os.environ["SLACK_WEBHOOK_URL"]).send(text="deploy finished")
```

Plain `requests` (no SDK):

```python
import requests

r = requests.post(
    "https://slack.com/api/chat.postMessage",
    headers={"Authorization": f"Bearer {os.environ['SLACK_BOT_TOKEN']}"},
    json={"channel": "C0123456789", "text": "hello"},
).json()
assert r["ok"], r["error"]
```

## Receiving events (slack_bolt, Socket Mode)

Socket Mode needs no public URL. Enable it in the app settings and create an
`xapp-` token with `connections:write`.

```python
import os
from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler

app = App(token=os.environ["SLACK_BOT_TOKEN"])

@app.message("ping")
def pong(message, say):
    say(text="pong", thread_ts=message["ts"])

@app.command("/hello")
def hello(ack, respond, command):
    ack()
    respond(f"hi <@{command['user_id']}>")

SocketModeHandler(app, os.environ["SLACK_APP_TOKEN"]).start()
```

## mrkdwn quick reference

```
*bold*  _italic_  ~strike~  `code`  ```block```  > quote
<https://example.com|label>   <@U0123456789>   <#C0123456789>   <!here>  <!channel>
```

Escape `&`, `<`, `>` as `&amp;`, `&lt;`, `&gt;` in text.

## Common errors

| error               | fix                                                              |
| ------------------- | ---------------------------------------------------------------- |
| `not_in_channel`    | `conversations.join` (public) or `/invite @app` in the channel   |
| `channel_not_found` | private channel the bot is not in, or wrong ID                   |
| `missing_scope`     | add the scope from `needed`, then reinstall the app             |
| `invalid_auth`      | wrong or revoked token, or wrong workspace                       |
| `ratelimited`       | honor `Retry-After`; tiers range from ~1 to ~100+ calls/min      |
