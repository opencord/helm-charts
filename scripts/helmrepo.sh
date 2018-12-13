#!/usr/bin/env bash

# Copyright 2018-present Open Networking Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# helmrepo.sh
# creates a helm repo for publishing on guide website

set -eu -o pipefail

# when not running under Jenkins, use current dir as workspace
WORKSPACE=${WORKSPACE:-.}

REPO_DIR="${REPO_DIR:-chart_repo}"

GERRIT_BRANCH="${GERRIT_BRANCH:-$(git symbolic-ref --short HEAD)}"
PUBLISH_URL="${PUBLISH_URL:-https://charts.opencord.org}"

mkdir -p "${REPO_DIR}"

while IFS= read -r -d '' chart
do
  chartdir=$(dirname "${chart}")

  echo "Adding ${chartdir}"

  helm package --dependency-update --destination "${REPO_DIR}" "${chartdir}"

done < <(find "${WORKSPACE}" -name Chart.yaml -print0)

echo "Generating repo index"

helm repo index "${REPO_DIR}" --url "${PUBLISH_URL}" --merge index.yaml

echo "Finished, chart repo generated: ${REPO_DIR}"

