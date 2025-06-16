#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=tyler36/ddev-site-metrics-nodejs

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site --project-type=generic
  assert_success
  # run ddev start -y
  # assert_success
}

health_checks() {
  # Check the server has started
  run curl -I "https://${PROJNAME}.ddev.site:8080/rolldice"
  assert_success
  assert_output --partial "HTTP/2 200"
}

setup_project() {
  # Copy over express project
  cd "${TESTDIR}"
  cp -a "${DIR}/tests/testdata/." "${TESTDIR}/"
  ddev npm i

  # Configure DDEV for express server
  cp -a "${TESTDIR}/config.express.yaml" "${TESTDIR}/.ddev/config.express.yaml"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail

  setup_project

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success

  run ddev restart -y
  assert_success
  health_checks
}

@test "it can collect traces" {
  set -eu -o pipefail

  setup_project

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success

  # Restrict otel to only what we need
  ddev dotenv set .ddev/.env.web --otel-logs-exporter=none >/dev/null 2>&1
  ddev dotenv set .ddev/.env.web --otel-metrics-exporter=none >/dev/null 2>&1
  ddev dotenv set .ddev/.env.web --otel-traces-exporter=console >/dev/null 2>&1

  run ddev restart -y
  assert_success

  # Check the logs do NOT contain trace output
  run ddev logs -s web
  assert_success
  refute_output --partial "'http.status_text': 'OK'"

  # Access website to generate traces
  run curl -I "https://${PROJNAME}.ddev.site:8080/rolldice"
  assert_success

  # Sleep for an arbitrary amount of time for logs to be written.
  sleep 5

  # Check the logs contain trace output
  run ddev logs -s web
  assert_success
  assert_output --partial "'http.status_text': 'OK'"
}

@test "it can collect traces via OTEL" {
  set -eu -o pipefail

  setup_project

  echo "# Install site-metrics" >&3
  run ddev addon get tyler36/ddev-site-metrics
  assert_success

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success

  # Remove NGINX port conflict as we're using Express.
  rm .ddev/docker-compose.nginx-exporter.yaml
  rm .ddev/nginx_full/stub_status.conf

  # Restrict otel to only what we need
  ddev dotenv set .ddev/.env.web --otel-logs-exporter=none >/dev/null 2>&1
  ddev dotenv set .ddev/.env.web --otel-metrics-exporter=otlp >/dev/null 2>&1
  ddev dotenv set .ddev/.env.web --otel-traces-exporter=otlp >/dev/null 2>&1

  run ddev restart -y
  assert_success

  # Check that there are no traces currently stored
  run ddev exec curl -G -s grafana-tempo:3200/api/search
  assert_success
  assert_output --partial '"traces":[]'

  # Access website to generate traces
  run curl -I "https://${PROJNAME}.ddev.site:8080/rolldice"
  assert_success
  # Wait for an arbitrary amount of time for the trace to propagate.
  sleep 5

  # Check that there are no traces currently stored
  run ddev exec curl -G -s grafana-tempo:3200/api/search
  assert_success
  assert_output --partial '"rootServiceName":"nodejs"'
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail

  setup_project

  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success

  run ddev restart -y
  assert_success
  health_checks
}
