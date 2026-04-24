# login with control over the browser
az login --use-device-code

# choose account (dev/prod)
az account set --subscription sub-enveda-data-dev-01

# ssh in
az ssh vm -g  data-science-dev-ncus-rg-01 --prefer-private-ip  -n johnprince-dev
