# install prefect with pip
# or go to to a repo with prefect installed, like enveda/prefect-flows or misosoup
prefect --help

### Login - interactive
prefect cloud login

###  Login - with api key (can get in UI)
prefect cloud login --key `cat ~/Dropbox/env/work/enveda/prefect/api/api_key-johnprince` --workspace enveda-bio/main

# ~/bin/work/prefect-feature-calling-custom-pairs
# (pairs.txt = two runs per line, space between them)
prefect-feature-calling-custom-pairs \
    pairs.txt \
    --misosoup-version 6.0 \
    --database ms_dev_jtp_paired_trash7 \
    --config-override "feature_calling.filter.ms1.remove_isopairs.enabled=False" \
    --config-override "feature_calling.filter.ms1.intensity_filter.enabled=True" \
    --config-override "peak_post_processing.multimodal.enabled=False"

# After submission, grab the id to inspect state
prefect flow-run inspect ecb1c9eb-9383-4d18-ad9a-69266a42384e


# change dev to a new branch

```
Go to github misosoup 
    -> Actions [tab at the top]
    -> All workflows  [ON THE LEFT!!!!]
        -> click [deploy-dev]
    -> Run workflow [on the right]
        -> pick your branch [dropdown]
        -> then click [Run workflow]
```

You get one major.minor deployment. So, if you deploy 5.6.11 then it will be
the 5.6 deployment. If you deploy 6.0.23, it will be the 6.0 deployment.


# Reference: How to run misosoup via prefect

https://www.notion.so/enveda/How-to-run-misosoup-via-prefect-7f25ad6963104104aeae63ecf387f697

| Name                                    | Description                                 |
|-----------------------------------------|---------------------------------------------|
| batch-feature-calling-unpaired/v0       | list “unpaired”                             |
| batch-feature-calling-custom-pairs/v0   | list “paired”                               |
| batch-feature-calling-spr-paired/v0     | list “paired” (common stockplate)           |
| batch-feature-calling-isolation-runs/v0 | isolat msrun_ids, pairs by bench sampleid\* |

\* if not found, runs unpaired
