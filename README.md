# ggml-k8

Can't find any H100s? Have no fear, with GGML and Kubernetes you can deploy Llama and Mistral using cheap AWS machines! This repo is a proof-of-concept llama.cpp deployment script for EC2 that scales automatically with Kubernetes.

![image](https://github.com/danielgross/ggml-k8/assets/279531/c64b04eb-bbf5-492b-8edb-c68b25817606)
<sub>*Image courtesy of [Lexica.art](https://lexica.art/aperture)*</sub>

----

### How to deploy
#### 1. Setup
Make sure you have the following installed:
- AWS CLI
- aws-iam-authenticator
- Docker
- kubectl
- eksctl

Then setup your AWS credentials by running the following commands:
```bash
export AWS_PROFILE=your_aws_profile
aws configure --profile your_aws_profile
```
Proceed to change the following files
1. .env:
Create a `.env` file, following the `.env.example` file, with the following variables:
- `AWS_REGION`: The AWS region to deploy the backend to.
- `MIN_CLUSTER_SIZE`: The minimum number of nodes to have on the Kubernetes cluster.
- `EC2_INSTANCE_TYPE`: The EC2 instance type to use for the Kubernetes cluster's node group.
- `ACM_CERTIFICATE_ARN`: The ARN of the ACM certificate to use for the domain.
- `DOMAIN`: The domain to use for the backend.

Currently only Route53 has been tested and is supported for the domain and ACM for the certificate. Make sure to have the Route53 hosted zone created and the ACM certificate validated.

2. models.yaml:
Add your models as shown in the `Uploading new models` section.

#### 2. Deploy
Initialize the Terraform infrastructure by running:
```bash
make deploy-terraform-aws
```
Then initialize the Kubernetes cluster by running:
```bash
make init-cluster-aws
```

#### 3. Enjoy
To test the deployed models with curl:
1. Get the filename from the url, e.g. from https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/blob/main/mistral-7b-instruct-v0.1.Q5_K_S.gguf the basename would be `mistral-7b-instruct-v0.1.Q5_K_S.gguf`.
2. Remove the extension and replace `_` and `.` with `-` and add `.api.$(YOURDOMAIN)` at the end.
3. Run requests on the model using the same OAI endpoints and adding the model basename from 1. on the `"model"` section of the data.

Example:
```
curl https://mistral-7b-instruct-v0-1-Q5-K-S.api.example.com/v1/chat/completions \
-H "Content-Type: application/json" \
-d '{
    "model": "mistral-7b-instruct-v0.1.Q5_K_S.gguf",
    "messages": [
        {"role": "user", "content": "How are you?"}
    ],
    "stream": true
}'
```
TODO: Create a proxy redirecting requests to the correct services automatically instead of having a different service API url for each model.

### Uploading new models
To upload a new model, identify the model's url, prompt template, requested resources and change the `models.yaml` file by adding the model following this example structure:
```yaml
  - url: "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/blob/main/mistral-7b-instruct-v0.1.Q5_K_S.gguf"
    promptTemplate: |
      <s>[INST] {{.Input}} [/INST] 
    resources:
      requests:
        cpu: 8192m
        memory: 16384Mi
```

Then, run the following command:
```bash
make update-kubernetes-cluster
```
This will automatically update the backend with the new model. Make sure to have the necessary resources available on the Kubernetes cluster to run the model.

### Destroying the backend
To destroy the Kubernetes cluster and backend resources run:
```bash
make destroy-terraform-aws
```

----

## Extra considerations
- The backend is currently set up on a single c5.18xlarge node in the `.env.example`, which might not be the best for your production environment. Make sure to change your .env file's `MIN_CLUSTER_SIZE` and `EC2_INSTANCE_TYPE` variables according to your needs.
- When a promptTemplate is defined, this is also used for the `/v1/completions` endpoint. This might be fixed in the future on LocalAI's end, in the meanwhile, if you just need to use the `/v1/completions` endpoint, make sure to not define the promptTemplate for the model on the `models.yaml` file at all.
- The requests can run in parallel thanks to an abstracted thread pool, through the use of multiple [LocalAI](https://github.com/mudler/LocalAI) horizontally scaled server instances.

### TO-DOs:
  - [ ] Add a proxy to redirect requests to the correct service and potentially collect all the /v1/models responses on a single endpoint.
  - [ ] Solve thread safety issues on [Llama.cpp](https://github.com/ggerganov/llama.cpp/issues/3960).
  - [ ] Make the backend more scalable by adding more nodes to the Kubernetes cluster automatically through an autoscaling group.
  - [ ] Test the backend on GPU enabled nodes.
  - [ ] Add support for other cloud providers.

Feel free to open an issue or a PR if you have any suggestions or questions!

----
### Authors 
[danielgross](https://github.com/danielgross) and [codethazine](https://github.com/codethazine).
