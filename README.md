<p align="center">
 <img src="./assets/favicon.png" alt="Kubestack, The Open Source Gitops Framework" width="25%" height="25%" />
</p>

<h1 align="center">Kubestack Catalog</h1>
<h3 align="center">Catalog for the Kubestack Gitops Framework</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/kbst/catalog.svg)](https://github.com/kbst/catalog/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/kbst/catalog.svg)](https://github.com/kbst/catalog/pulls)

</div>

<div align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/kbst/catalog?style=social)
![Twitter Follow](https://img.shields.io/twitter/follow/kubestack?style=social)

</div>


<h3 align="center"><a href="#Contributing">Join Our Contributors!</a></h3>

<div align="center">

<a href="https://github.com/kbst/catalog/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=kbst/catalog&max=36" />
</a>

</div>

## Introduction

This repository holds the kustomize source manifests and build toolchain for the [Kubestack catalog of Kustomize bases](https://www.kubestack.com/catalog).

This is maintained as part of the [Terraform GitOps framework Kubestack](https://www.kubestack.com/).


## Getting Started with Kubestack

For the easiest way to get started, [visit the official Kubestack quickstart](https://www.kubestack.com/infrastructure/documentation/quickstart). This tutorial will help you get started with the Kubestack GitOps framework. It is divided into three steps.

1. Develop Locally
    * Scaffold your repository and tweak your config in a local development environment that simulates your actual cloud configuration using Kubernetes in Docker (KinD).
3. Provision Infrastructure
    * Set-up cloud prerequisites and bootstrap Kubestack's environment and clusters on your cloud provider for the first time.
4. Set-up Automation
    * Integrate CI/CD to automate changes following Kubestack's GitOps workflow.

See the [`tests`](./tests) directory for an example of how to extend this towards multi-cluster and/or multi-cloud.


## Getting Help

**Official Documentation**  
Refer to the [official documentation](https://www.kubestack.com/framework/documentation) for a deeper dive into how to use and configure Kubetack.

**Community Help**  
If you have any questions while following the tutorial, join the [#kubestack](https://app.slack.com/client/T09NY5SBT/CMBCT7XRQ) channel on the Kubernetes community. To create an account request an [invitation](https://slack.k8s.io/).

**Professional Services**  
For organizations interested in accelerating their GitOps journey, [professional services](https://www.kubestack.com/lp/professional-services) are available.


## Contributing
Contributions to the Kubestack framework are welcome and encouraged. Before contributing, please read the [Contributing](./CONTRIBUTING.md) and [Code of Conduct](./CODE_OF_CONDUCT.md) Guidelines.

One super simple way to contribute to the success of this project is to give it a star.  

<div align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/kbst/catalog?style=social)

</div>


## Development Workflow

1. Fork this repository
1. Work in a feature branch
1. Validate your changes locally
   ```
   # Build the helper image
   # optional `--build-arg KUSTOMIZE_VERSION=3.2.3`
   docker build -t python3-kustomize .

   # Run dist.py to generate the archives
   docker run \
       --rm \
       -u `id -u`:`id -g` \
       -v `pwd`:/workspace \
       -w /workspace \
       -e GIT_SHA=`git rev-parse --verify HEAD^{commit}` \
       -e GIT_REF=refs/heads/`git rev-parse --abbrev-ref HEAD` \
       python3-kustomize \
       ./dist.py

   # Run test.py to test your changes
   docker run \
       --rm \
       -u `id -u`:`id -g` \
       -v `pwd`:/workspace \
       -w /workspace \
       python3-kustomize \
       ./test.py

   ```
1. Send a pull-request


## Making a Release

1. Create a Git tag in the format `name-version`
   * name must be the name of the catalog entry to release, e.g. `memcached`
   * version must be in format `major.minor.patch` prefixed with a `v`,
     e.g. `v0.0.1`
2. Push the tag to trigger CI/CD


## Kubestack Repositories
* [kbst/terraform-kubestack](https://github.com/kbst/terraform-kubestack)  
    * Terraform GitOps Framework - Everything you need to build reliable automation for AKS, EKS and GKE Kubernetes clusters in one free and open-source framework.
* [kbst/kbst](https://github.com/kbst/kbst)  
    * Kubestack Framework CLI - All-in-one CLI to scaffold your Infrastructure as Code repository and deploy your entire platform stack locally for faster iteration.
* [kbst/terraform-provider-kustomization](https://github.com/kbst/terraform-provider-kustomization)  
    * Kustomize Terraform Provider - A Kubestack maintained Terraform provider for Kustomize, available in the [Terraform registry](https://registry.terraform.io/providers/kbst/kustomization/latest).
* [kbst/catalog](https://github.com/kbst/catalog) (this repository)  
    * Catalog of cluster services as Kustomize bases - Continuously tested and updated Kubernetes services, installed and customizable using native Terraform syntax.

