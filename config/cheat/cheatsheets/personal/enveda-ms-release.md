
1. make a ms-toolkit release (doesn't have to be, since could point to a git tag)
	gh release create --generate-notes
2. make a branch on enveda ms (make it very small lenght name)
3. make a PR
4. make a dev deployment

	gh workflow run deploy-dev.yml --ref $(git branch --show-current)

5. Then go to your Actions tab of your PR, make sure it succeeds
6. 


flow: enveda-ms.feature-calling-ground-truth-runs
find the flow, hit the deployments tab (internal tab, not on the left)
Pick the dev deployment
Then click run

Or, just go to this link:


Hit Run button
	- quickrun

	A. ms_version ms_8_4 <<-- this needs to match the version of enveda MS you set!!
	B. split (probably test)
	C. use_deployment_name
	     dev-{branch_name}-{ms_version}
	     eg.: dev-contig-caller-ms_8_4 (if the branch is contig-caller)


https://prefect.dev.enveda.io/flows/flow/97328f0a-cae1-4928-97a4-8d6f42300fdb?tab=Deployments&deployments.deployments.flowOrDeploymentNameLike=contig&deployments.limit=100

Can search for deployment name based on branch name here ^

Or, can see the deployment name by searching for your branch in the github actions log, "deploy flows to prod" (mis-named, should be deploy flows to dev!)


```
{
  "split": "test",
  "rerun_all": false,
  "use_large_compute": false,
  "run_options": null,
  "timeout": 0,
  "ms_version": "ms_8_0",
  "use_deployment_name": "dev-contig-caller-ms_8_0"
}
```

{
  "split": "test",
  "rerun_all": false,
  "use_large_compute": false,
  "run_options": null,
  "timeout": 0,
  "ms_version": "ms_8_0",
  "use_deployment_name": "dev-ms_8_5"
}

## Now you need to calculate the ground truth metrics
platform-metrics.calculate-ground-truth-metrics

