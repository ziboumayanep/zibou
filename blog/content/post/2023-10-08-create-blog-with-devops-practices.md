---
title: "Reviving My Blog: A DevOps Journey to GCP Deployment"
date: 2023-10-08
tags:
  - DevOps
  - GCP
  - Hugo
---

Four years have passed since my last blog post, and during that time, my interests in technology have evolved, steering me towards DevOps and automation practices. With newfound free time, I decided to embark on a side project that would allow me to apply my recent knowledge in the field of DevOps. This led me to a compelling idea: why not treat my blog as a service and leverage DevOps practices to deploy it on Google Cloud Platform (GCP)?

Here are the technical requirements I set for this project:

- Containerization: I aimed to encapsulate my Hugo website within a Docker image, equipped with an Nginx server to serve the static content.

- Kubernetes Deployment: The Docker container would be orchestrated as a deployment within a Kubernetes Cluster (K8s).

- Service Exposition: To make the blog accessible, the K8s cluster would expose the deployment through a service.

- Ingress Management: I planned to set up an ingress controller to expose the service, utilizing a managed load balancer provided by GCP. By default, the protocol HTTPS would be employed, complete with a certificate for secure access.

In addition to the technical aspects, I also integrated DevOps best practices into my project:

- Git-Based Management: All the code related to my blog, including the Dockerfile and K8s YAML files, would be version-controlled using Git.

- Infrastructure as Code: I committed to managing all the infrastructure-related code within Git as well, ensuring transparency and consistency.

- CI/CD Pipeline: My CI/CD (Continuous Integration/Continuous Deployment) pipeline would be configured to automatically deploy the infrastructure and the blog whenever there is a commit to the main branch.

While these requirements already posed a significant challenge, I decided to forgo the complexity of multi-environment deployment, focusing on the initial development stages of the project. This ambitious undertaking represents a step forward in both my technical and DevOps expertise, and I'm excited to share the journey and insights gained along the way in upcoming blog posts. Stay tuned for updates!

I've come across something fascinating—an entire [movement](https://cloudresumechallenge.dev/docs/the-challenge/googlecloud/) inspired by this concept, initiated by Forrest Brazeal. His ingenious idea has had a remarkable impact on countless individuals, playing a pivotal role in helping them secure employment opportunities. You can learn more about this movement here.

# Hugo and container

[Hugo](https://gohugo.io/) stands out as an exceptionally fast static website generator framework, allowing me to effortlessly transform markdown content into a visually stunning blog. Among its many capabilities, the one that truly shines for me is its exceptional code formatting features, making Hugo the perfect choice for my blogging needs.
