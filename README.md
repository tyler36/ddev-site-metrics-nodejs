[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/tyler36/ddev-site-metrics-nodejs/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/tyler36/ddev-site-metrics-nodejs/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/tyler36/ddev-site-metrics-nodejs)](https://github.com/tyler36/ddev-site-metrics-nodejs/commits)
[![release](https://img.shields.io/github/v/release/tyler36/ddev-site-metrics-nodejs)](https://github.com/tyler36/ddev-site-metrics-nodejs/releases/latest)

# DDEV Site Metrics Nodejs

## Overview

This add-on integrates Site Metrics Nodejs into your [DDEV](https://ddev.com/) project.

## Installation

```bash
ddev add-on get tyler36/ddev-site-metrics-nodejs
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev describe` | View service status and used ports for Site Metrics Nodejs |
| `ddev logs -s site-metrics-nodejs` | Check Site Metrics Nodejs logs |

## Advanced Customization

To change the Docker image:

```bash
ddev dotenv set .ddev/.env.site-metrics-nodejs --site-metrics-nodejs-docker-image="busybox:stable"
ddev add-on get tyler36/ddev-site-metrics-nodejs
ddev restart
```

Make sure to commit the `.ddev/.env.site-metrics-nodejs` file to version control.

All customization options (use with caution):

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `SITE_METRICS_NODEJS_DOCKER_IMAGE` | `--site-metrics-nodejs-docker-image` | `busybox:stable` |

## Credits

**Contributed and maintained by [@tyler36](https://github.com/tyler36)**
