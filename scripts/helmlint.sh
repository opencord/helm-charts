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

# helmlint.sh
# run `helm lint` on all helm charts that are found

set +e -o pipefail

# verify that we have helm installed
command -v helm >/dev/null 2>&1 || { echo "helm not found, please install it" >&2; exit 1; }

echo "helmlint.sh, using helm version: $(helm version -c --short)"

fail_lint=0

# when not running under Jenkins, use current dir as workspace
WORKSPACE=${WORKSPACE:-.}

# cleanup repos if `clean` option passed as parameter
if [ "$1" = "clean" ]
then
  echo "Removing dependent charts"
  find "${WORKSPACE}" -name 'charts' -exec rm -rf {} \;
fi

while IFS= read -r -d '' chart
do
  chartdir=$(dirname "${chart}")

  # only update dependencies for profiles
  if [[ $chartdir =~ xos-profiles || $chartdir =~ workflows ]] && [ -f "${chartdir}/requirements.yaml" ]
  then
    helm dependency update "${chartdir}"
  fi

  # lint with values.yaml if it exists
  if [ -f "${chartdir}/values.yaml" ]; then
    helm lint --strict --values "${chartdir}/values.yaml" "${chartdir}"
  else
    helm lint --strict "${chartdir}"
  fi

  rc=$?
  if [[ $rc != 0 ]]; then
    fail_lint=1
  fi
done < <(find "${WORKSPACE}" -name Chart.yaml -print0)

if [[ $fail_lint != 0 ]]; then
  exit 1
fi

exit 0
