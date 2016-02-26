
- rename Parser as OptionParser (see specdown)

---

$ bosh-tools fly config pipeline-name/job-name my-config # writes to ~/.fly/config/... by convention
$ bosh-tools fly exec pipeline.yml/job-name -c pipeline-name/job-name my-config

$ bosh-tools fly exec pipeline.yml/job-name                                     # prompt for all params, and write to script
$ bosh-tools fly exec pipeline.yml/job-name -c pipeline-name/job-name           # pull params from running pipeline, and write to script
$ bosh-tools fly exec pipeline.yml/job-name -l config-name                      # ...

source <(openssl ... ~/.fly/config/my-config)

```
#!/usr/bin/env bash
#
# Generated at 2016-02-24 11:01:34 -0800 using:
# 'bosh-tools fly exec ./ci/pipeline.yml:bats-ubuntu -t production -c bosh-aws-cpi/bats-ubuntu -j bosh-aws-cpi/bats-ubuntu -i bosh-release=/tmp/bosh-release -i stemcell=/tmp/stemcell'

set -e

: ${TEMP_FOLDER:=$(mktemp -d -t fly-exec)}
: ${CONCOURSE_TARGET:=production}

[[ "$CONCOURSE_TARGET" != "" ]] && target="-t ${CONCOURSE_TARGET}" || target=""

source ${config_file:-config-name}

echo "task outputs will be written to ${TEMP_FOLDER}"

echo "task: setup-director..."

fly ${target} execute -c ./ci/tasks/setup-director.yml -j bosh-aws-cpi/bats-ubuntu -i bosh-release=/tmp/bosh-release -i stemcell=/tmp/stemcell -o deployment=${TEMP_FOLDER}/deployment

echo "task: run-bats..."

fly ${target} execute -c ./ci/tasks/run-bats.yml -j bosh-aws-cpi/bats-ubuntu -i deployment=${TEMP_FOLDER}/deployment -i bosh-release=/tmp/bosh-release -i stemcell=/tmp/stemcell

echo "task: teardown-director..."

fly ${target} execute -c ./ci/tasks/teardown-director.yml -j bosh-aws-cpi/bats-ubuntu -i deployment=${TEMP_FOLDER}/deployment -i bosh-release=/tmp/bosh-release -i stemcell=/tmp/stemcell

echo "outputs (${TEMP_FOLDER})..."
ls -l ${TEMP_FOLDER}
```
