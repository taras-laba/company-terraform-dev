# company-terraform-dev

### Authenticate to Cloud Artifactory 
```
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### Company Ingestion Job

```
docker build -f ./src/Company.IngestionJob/Dockerfile . -t us-central1-docker.pkg.dev/taras-laba-dev/company-repo/company-ingestion-job:latest
```

```
docker push us-central1-docker.pkg.dev/taras-laba-dev/company-repo/company-ingestion-job:latest
```

### Company Ingestion Consumer
```
docker build -f .\src\Company.IngestionConsumer\Dockerfile . -t us-central1-docker.pkg.dev/taras-laba-dev/company-repo/company-ingestion-consumer:latest
```
```
docker push us-central1-docker.pkg.dev/taras-laba-dev/company-repo/company-ingestion-consumer:latest
```
```
 gcloud run deploy company-sync-worker --image=us-central1-docker.pkg.dev/taras-laba-dev/company-repo/company-ingestion-consumer:latest
 gcloud run deploy company-ingestion-consumer --image=us-central1-docker.pkg.dev/taras-laba-dev/company-repo/company-ingestion-consumer:latest
 ```
### Company Api
```
docker build -f .\src\Company.Api\Dockerfile . -t us-central1-docker.pkg.dev/taras-laba-dev/company-repo/company-api:latest
```
```
docker push us-central1-docker.pkg.dev/taras-laba-dev/company-repo/company-api:latest
```
```
gcloud run deploy company-api --image=us-central1-docker.pkg.dev/taras-laba-dev/company-repo/company-api:latest

```
```
gcloud auth print-identity-token --impersonate-service-account company-api-invoker-sa@taras-laba-dev.iam.gserviceaccount.com --audiences='company-api'
```