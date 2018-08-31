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

# wait_for_jobs.sh
# waits for all kubernetes jobs to complete before exiting
# inspired by similar scripts in Kolla-Kubernetes and Openstack Helm

set -eu -o pipefail
fail_wfj=0

# Set these to configure maximum timeout, and interval for checks
JOBS_TIMEOUT=${JOBS_TIMEOUT:-600}
CHECK_INTERVAL=${CHECK_INTERVAL:-5}
KUBECTL_ARGS=${KUBECTL_ARGS:-}

# calculate timeout time
START_TIME=$(date +%s)
END_TIME=$((START_TIME + JOBS_TIMEOUT))

echo "wait_for_jobs.sh - Waiting up to ${JOBS_TIMEOUT} seconds for all Kubernetes jobs to complete"
echo "Number printed is number of currently active jobs"

prev_job_count=0

while true; do
  NOW=$(date +%s)

  # handle timeout without completion
  if [ "$NOW" -gt "$END_TIME" ]
  then
    echo "Jobs didn't complete before timeout of ${JOBS_TIMEOUT} seconds"
    fail_wfj=1
    break
  fi

  # get list of active jobs, and count of them
  # jsonpath is picky about string vs comparison quoting, so have to have:
  # shellcheck disable=SC2026,SC2086
  active_jobs=$(kubectl get jobs $KUBECTL_ARGS -o=jsonpath='{range .items[?(@.status.active=='1')]}{.metadata.name}{"\n"}{end}')

  # this always is 1 or more, as echo leaves a newline in the output which wc
  # counts as a line
  active_job_count=$(echo -n "${active_jobs}" | wc -l)

  # if no jobs active, print runtime and break
  if [ -z "$active_jobs" ]
  then
    runtime=$((NOW - START_TIME))
    echo ""
    echo "All jobs completed in $runtime seconds"
    break
  fi

  # deal with changes in number of jobs
  if [ "$active_job_count" -ne "$prev_job_count" ]
  then
    echo ""
    echo "Number of active jobs changed - current jobs:"
    echo "$active_jobs"
  fi
  prev_job_count=$active_job_count

  # print number of remaining jobs every $CHECK_INTERVAL
  echo -n "$active_job_count "
  sleep "$CHECK_INTERVAL"
done

echo ""
echo "Job Status - Name | Start Time | Completion Time"
# shellcheck disable=SC2086
kubectl get jobs $KUBECTL_ARGS -o=jsonpath='{range .items[*]}{.metadata.name}{"\t| "}{.status.startTime}{" | "}{.status.completionTime}{"\n"}{end}'

exit ${fail_wfj}
