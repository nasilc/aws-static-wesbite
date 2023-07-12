# ☁️ AWS Static HTML Website

## Overview

This project deploys a static html website in AWS.

## URL

Deployed website: https://lisan-static-website.s3.ap-southeast-2.amazonaws.com/index.html

## 🚧 Methodology

This website utilises a public AWS S3 bucket to host the website. Terraform and GitHub Actions are used to provision the bucket and configure it to host the static webpage.

## 💭 Reasoning 

### S3 Bucket Approach

AWS has multiple services that could be configured to host this static website. 
- **Containerised**: Building the webpage as a container (potentially utilising nginx container as a simple example) and hosting the container using AWS ECS or EKS.
- **Serverless**: Utilising AWS lambda to host the application utilising serverless computing. This would be useful if the team in question were not focussed on server maintenance skills. 
- **Server-hosted**: Utilising AWS EC2 to host the website on a server.

Ultimately, the S3 bucket solution was selected in accordance with the requirements. The website was required to serve only static text, which would only require an html file to be served and S3 buckets have an in-built method of hosting static files. If the requirements evolve in future to a more complex and interactive website, the approach would definitely need to be altered, and would lean toward the containerised approach to enable more quick and agile development.

### Terraform vs AWS CLI/AWS API vs AWS UI

The solution chosen to provision this website was Terraform. Alternatives include AWS UI and AWS CLI/API.

AWS UI was not chosen in accordance with infrastructure as code and continuous integration/delivery principles. In order to build the infrastructure provisioning steps into pipeline, a CLI approach such as with terraform or AWS CLI was much preferred. Further, if infrastructure is defined as code, the steps are much more repeatable and scalable if the website needs to be migrated, rolled back, scaled up or updated in future.

Between AWS CLI and Terraform, the competition was closer as both tools are very flexible and feature rich when provisioning AWS services. Ultimately, went with terraform to be more cloud agnostic and because there were simple pre-built modules for terraform with GitHub actions. Further, the choice was also based on convenience as I already had terraform installed in my local environment for easy testing and I am more familiar with terraform. However, if this were an application to be maintained long term, I would have researched more thoroughly on the benefits and drawbacks of both approaches and made a decision in conjunction with the team, the requirements and the future plan.

## Production Considerations

Before this website can be considered production grade for multiple teams to develop on, there are multiple areas of consideration.

### CI/CD

To enable continuous integration and continuous integration, delivery and deployment, there are a number of enhancements to incorporate into the existing pipeline.
​​
- **Staging environment**: The existing workflow currently only triggers on the master branch. A staging environment should be set up to enable developers to build and manually test their code changes in a production-mirrored environment prior to pushing into the production branch. A new staging branch should be created, and new workflows built for the staging environment such that pushing and testing in the staging environment is a prerequisite of pushing into production.
- **Utilising branching rather than pushing**: The existing pipeline trigger is on a push to master branch; however, in order to minimise merge conflicts and enable continuous integration, feature branching, then merging into staging/master branches should be encouraged. Direct pushes into master and staging branches should not be permitted.
- **Automated testing**: Currently, the pipeline validates then applies the terraform configuration. Additional steps should also be added into this pipeline to automate testing. Most importantly, unit testing steps should be added into the workflow, but other types of tests such as integration and functional testing should also be added in as required.
- **Versioning**: For documentation purposes, the pipeline should also be altered to ensure that all releases into staging and production have an associated version tag and release notes if required.
- **Rollback**: An automated rollback workflow should also be developed and tested to ensure that if something were to go wrong in a deployment, the change can be efficiently rolled back to minimise downtime.

### Security

- **Purchase and register domain name**: Security is of utmost importance to a production-deployed website. To ensure user security, a proper domain name will need to be purchased and registered. The website will need to utilise https and serve a valid certificate, signed by a legitimate certificate authority.
- **Secure Secret Storage**: Importantly, the current secret storage method is GitHub Secrets (secrets have since been removed). GitHub Secrets simply saves the secret as an environment variable which anyone with access to the repository can enter and echo. A more secure method of secret storage will need to be utilised such as HashiCorp Vault. 
- **Minimise use of non-expiring secrets**: There are also methods to authenticate directly with the cloud provider rather than relying on a one-time generated and static access/secret key pair - these methods will be preferred in order to minimise the need to have sensitive data stored. If a static secret is required, it would be ideal to automate the rotation of these secrets such that old secrets will be expired / revoked and no non-expiring secrets to be found.
- **RBAC for engineers working on the codebase**: Currently, the project is hosted publicly at Github.com. Access to make changes into the repo should be more tightly controlled and the relevant engineers given only the permissions they need and no more (principle of least privilege). The repo should be potentially made private, and to ensure a higher level of security, would ideally be hosted on a corporate GitHub instance.
- **Security scanning**: Ideally, security scans will be incorporated into the pipeline. Code scans utilising tools such a sonarqube should be conducted and the results presented back to the developer. Merges into protected branches should require the developer to investigate and address the code scan results before they can be completed. Aside from code scanning, if this web application evolves to be containerised, container build time (and runtime) scanning will also ideally be incorporated.

### Reliability
- **Auto scaling to match demand**: Currently, the website exists as a single S3 bucket, As the website and customer base evolves, traffic will increase and resources required will also increase. Other AWS services that enable auto scaling of resources/containers to match with demand are important from both a customer experience and cost perspective.
- **Monitoring, Alerting and Logging**: Assuming the website will become more interactive, it will become increasingly important to track activity and customer experience on the website. This will be done by generating key metrics and logs, then developing key alerts when certain thresholds are breached or errors occur. It will also be helpful to generate a dashboard that utilises the logs and metrics to present a summary of the system. On AWS this can be done with CloudWatch, however, external tools such as Grafana/Prometheus/ElasticSearch can also be integrated if more flexibility is required.
- **Geo-Redundancy**: Currently, this application is deployed in only one region but across multiple availability zones in accordance with the principles of Amazon S3 storage. This can be improved by potentially deploying across multiple regions. If the customer base evolves to include global customers, multiple regions will also be important to minimise latency.

## ➡️ Next Steps

If I had more time, there are a number of enhancements to this project to pursue. Some of the key short-term enhancements I would have added:
- Improve the file structure of the repo. Currently the github actions are in their own folder but otherwise everything is in root. I would create folders to separate terraform from application code. Further, I would modularise the terraform configuration.
- Build this as a containerised application for future scalability.
- Security hardening: authenticate directly with AWS Cloud or utilise more secure methods of secret storage.
