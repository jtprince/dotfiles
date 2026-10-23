# bitwarden-cli

```
# brew/yay bitwarden-cli

bw login
export BW_SESSION="$(bw unlock --raw)"
bw sync

bw get password "My Service"
bw get username "My Service"

# retrieve a custom field
bw get item "My Service Name" | jq -r '.fields[] | select(.name=="MY_CUSTOM_FIELD") .value'

# Easier
bw-get-field "My Service" api-key
```
