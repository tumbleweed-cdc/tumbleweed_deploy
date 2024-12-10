![Tumbleweed](https://raw.githubusercontent.com/tumbleweed-cdc/.github/171c43760709c6998007793df34de60e8352c56e/profile/tumbleweed_logo_rectangle.svg)

## 🚀 Deployment

Tumbleweed provides a custom Command Line Interface (CLI) tool and uses Terraform to provision and deploy Tumbleweed pipelines on AWS ECS (Elastic Cloud Services) using Fargate.

Prerequisites:

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
---
🌵 Developed By: 
[Cruz Hernandez](https://github.com/archzedzenrun) | 
[Nick Perry](https://github.com/nickperry12) |
[Paco Michelson](https://github.com/jeffbbz) |
[Esther Kim](https://github.com/ekim1009) 🤝