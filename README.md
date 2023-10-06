# zibou

Thing to do after creating the project

`gcloud storage buckets create gs://ziboumima-tf-state`

for terraform to make request

`gcloud services enable serviceusage.googleapis.coms`

create token from github
[docs](https://cloud.google.com/build/docs/automating-builds/github/connect-repo-github?generation=2nd-gen)

```
Make sure to set your token to have no expiration date and select the following permissions when prompted in GitHub: repo and read:user. If your app is installed in an organization, make sure to also select the read:org permission.
```

create secret to store github credentials

echo -n <TOKEN> | gcloud secrets create github_token --data-file=-
