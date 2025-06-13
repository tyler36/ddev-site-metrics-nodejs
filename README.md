[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/tyler36/ddev-site-metrics-nodejs/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/tyler36/ddev-site-metrics-nodejs/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/tyler36/ddev-site-metrics-nodejs)](https://github.com/tyler36/ddev-site-metrics-nodejs/commits)
[![release](https://img.shields.io/github/v/release/tyler36/ddev-site-metrics-nodejs)](https://github.com/tyler36/ddev-site-metrics-nodejs/releases/latest)

# DDEV Site Metrics Nodejs

## Overview

This add-on add support for Open Telemetry via zero-instrumentation. It helps automate the steps to setup and then collect data.

It is designed to support [tyler36/ddev-site-metrics](https://github.com/tyler36/ddev-site-metrics), an add-on designed to consume collected logs, metrics and traces.

## Installation

```bash
ddev add-on get tyler36/ddev-site-metrics-nodejs
ddev restart
```

## Usage

1. Inject instrumentation _before_ JavaScript process.

For example. An project uses the following node script to launch their server in `packages.json`:

```json
  "scripts": {
    "dev": "node app.js",
    ...
  },
```

Using this add-on, require instrumentation _before_ initializing your node script:

```json
  "scripts": {
    "dev": "node --require @opentelemetry/auto-instrumentations-node/register app.js",
    ...
  },
```

1. Start your Node server

```shell
ddev npm run dev
```

This add-on is configured via environmental variables, typically in `.ddev/.env.web`.
It is recommended to limit variables to the web container to prevent leakage.

The following example sends logs to the console:

```env
OTEL_TRACES_EXPORTER=console
```

- starting your server `ddev npm run dev`, you will see traces outputted in the terminal.

- if you using a `web_deamon` method to automatically start the server, use the following to view traces:

```shell
ddev log -s web
```

### Configuration for ddev-site-metrics

The following example send traces to [tyler36/ddev-site-metrics](https://github.com/tyler36/ddev-site-metrics) for processing.

```env
OTEL_TRACES_EXPORTER=otlp
OTEL_EXPORTER_OTLP_ENDPOINT=http://grafana-alloy:4318
```

## Advanced Customization

### Environmental Variables

This add-on sets environmental variables in `.ddev/.env.web`:

- `OTEL_SERVICE_NAME="nodejs"`: The service name assigned to collected data.
- `OTEL_EXPORTER_OTLP_ENDPOINT="http://grafana-alloy:4318"`: The base endpoint, as provided by `ddev-site-metrics` add-on.

If these values are changed, you must restart DDEV for them to take affect.
For other methods to override the, see [Environment Variables for Containers and Services](https://ddev.readthedocs.io/en/stable/users/extend/customization-extendibility/).

## Credits

**Contributed and maintained by [@tyler36](https://github.com/tyler36)**
