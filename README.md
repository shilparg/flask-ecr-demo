# flask-ecr-demo

Flask App Deployment to AWS ECR via GitHub Actions

# Flask ECR Demo

A containerized Flask app deployed to AWS ECR and ECS using GitHub Actions. Supports immutable image tagging, CI/CD automation, and audit-ready infrastructure.

## CI/CD Status

| Badge                                                                                                  | Description                        |
| ------------------------------------------------------------------------------------------------------ | ---------------------------------- |
| ![Build Status](https://github.com/<USERNAME>/flask-ecr-demo/actions/workflows/ecr-push.yml/badge.svg) | GitHub Actions build & push status |
| ![Latest Tag](https://img.shields.io/badge/tag-latest-blue)                                            | Docker image with `latest` tag     |
| ![SHA Tag](https://img.shields.io/badge/tag-${{ github.sha }}-green)                                   | Unique image tag per commit        |
| ![ECR Push](https://img.shields.io/badge/ECR-pushed-success)                                           | Image successfully pushed to ECR   |

## Stack

- Flask (Python 3.10)
- Docker
- AWS ECR
- AWS ECS (Fargate)
- GitHub Actions

## Features

- Immutable image tagging with `github.sha`
- CI/CD pipeline triggered on `main` branch push
- ECS deployment via GitHub Actions
- Modular Makefile and shell scripts
