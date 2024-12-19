![Tumbleweed](https://raw.githubusercontent.com/tumbleweed-cdc/.github/171c43760709c6998007793df34de60e8352c56e/profile/tumbleweed_logo_rectangle.svg)

## 🌵 What is Tumbleweed?

Tumbleweed is an open-source, user-friendly framework designed for fast and consistent data propagation between microservices using Change Data Capture (CDC) and the transactional outbox pattern.
It automatically deploys a self-hosted log-based CDC pipeline that abstracts away the complexities associated with setting up and using CDC tools. It is designed to monitor changes in one or more PostgreSQL databases and sync that data to consumer microservices in near real-time.

For more information check out our [case study](https://tumbleweed-cdc.github.io/docs/introduction/) or the [Tumbleweed GitHub](https://github.com/tumbleweed-cdc)

## 🚀 Deployment

### ⚙️ Automated Deployment

A Command-Line Interface (CLI) tool is provided to automatically deploy self-hosted Tumbleweed pipelines to Amazon Web Services (AWS).

**Prerequisites:**

* An Amazon Web Services (AWS) account
* IP address(es) that will have access to the Tumbleweed UI
* Install [AWS CLI](https://aws.amazon.com/cli/)
* Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

You are now ready to deploy Tumbleweed!

Run the following command in your command line to get started:

```
npx tumbleweed_cdc roll
```

The pipeline can be destroyed with the following command:

```
npx tumbleweed_cdc burn
```
⚠️ Destroying the pipeline will permanently delete all associated resources and data.
