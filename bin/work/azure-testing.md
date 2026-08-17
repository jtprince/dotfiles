# Testing the azure-blob-* scripts

Safe sandbox to exercise `azure-blob-ls`, `azure-blob-upload`,
`azure-blob-download`, and `azure-blob-rename` against real Azure. Nothing
under this location is precious — create, overwrite, and delete freely.

- subscription: `sub-enveda-data-dev-01`
- storage account: `miscdevncus01`
- container: `user-junk-365d-delete`
- test prefix: `jtprince/azure-blob-testing/`

That container auto-purges anything older than 365 days, so a stray leftover
test blob isn't a real problem — but clean up after yourself anyway (last
step below).

## Setup

```
S=sub-enveda-data-dev-01
A=miscdevncus01
C=user-junk-365d-delete
P=jtprince/azure-blob-testing

mkdir -p /tmp/azure-blob-test
echo "hello a" > /tmp/azure-blob-test/a.txt
echo "hello b" > /tmp/azure-blob-test/b.txt
```

## 1. upload

```
uv run azure-blob-upload \
    --subscription $S --storage-account $A --container $C \
    --upload-dir $P \
    /tmp/azure-blob-test/a.txt /tmp/azure-blob-test/b.txt
```

## 2. ls

```
uv run azure-blob-ls --subscription $S --storage-account $A \
    "az://$C/$P/"
```

Expect to see `a.txt` and `b.txt`.

## 3. rename — dry run

```
cat > /tmp/azure-blob-test/pairs.txt <<EOF
az://$C/$P/a.txt az://$C/$P/a-renamed.txt
az://$C/$P/b.txt az://$C/$P/b-renamed.txt
EOF

uv run azure-blob-rename --storage-account $A --dry-run /tmp/azure-blob-test/pairs.txt
```

Expect the two planned renames printed, no Azure calls made.

## 4. rename — real run

```
uv run azure-blob-rename \
    --subscription $S --storage-account $A \
    /tmp/azure-blob-test/pairs.txt
```

Expect both renames to report `✓`. Verify:

```
uv run azure-blob-ls --subscription $S --storage-account $A "az://$C/$P/"
```

Expect `a-renamed.txt` and `b-renamed.txt` present, `a.txt`/`b.txt` gone.

## 5. download (optional sanity check)

```
uv run azure-blob-download \
    --subscription $S --storage-account $A --container $C \
    --download-dir $P --output-dir /tmp/azure-blob-test/downloaded \
    a-renamed.txt b-renamed.txt
```

## 6. clean up

Leave the test prefix empty when done:

```
az storage blob delete-batch \
    --account-name $A --source $C --pattern "$P/*" \
    --auth-mode login
```
