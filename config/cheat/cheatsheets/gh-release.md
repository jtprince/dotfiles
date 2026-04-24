```bash
# prep
git checkout main
git pull
# OR
git-fetch-and-delete-locally

_VERSION=`uv version --short`
_VERSION_TAG="v$_VERSION"
echo "$_VERSION"
echo "$_VERSION_TAG"

gh release create "$_VERSION_TAG" --generate-notes --target main
git fetch origin --tags
git tag
```
