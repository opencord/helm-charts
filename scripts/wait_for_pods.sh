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

# wait_for_pods.sh
# waits for all kubernetes pods to complete before exiting, optionally only
# pods in a specific namespace passed as first argument
# inspired by similar scripts in Kolla-Kubernetes and Openstack Helm

set -e -o pipefail
fail_wfp=0

# Set these to configure maximum timeout, and interval for checks
PODS_TIMEOUT=${PODS_TIMEOUT:-600}
CHECK_INTERVAL=${CHECK_INTERVAL:-5}
KUBECTL_ARGS=${KUBECTL_ARGS:-}

# use namespace if passed as first arg, or "all" for all namespaces
if [ ! -z "$1" ]
then
  if [[ "$1" == "all" ]]
  then
    KUBECTL_ARGS+=" --all-namespaces"
  else
    KUBECTL_ARGS+=" --namespace=$1"
  fi
fi
set -u

# calculate timeout time
START_TIME=$(date +%s)
END_TIME=$((START_TIME + PODS_TIMEOUT))

echo "wait_for_pods.sh - Waiting up to ${PODS_TIMEOUT} seconds for all Kubernetes pods to be ready"
echo "Number printed is number of jobs/pods/containers waiting to be ready"

prev_total_unready=0

while true; do
  NOW=$(date +%s)

  # handle timeout without completion
  if [ "$NOW" -gt "$END_TIME" ]
  then
    echo "Pods/Containers/Jobs not ready before timeout of ${PODS_TIMEOUT} seconds"
    fail_wfp=1
    break
  fi

  # get list of uncompleted items with jsonpath, then count them with wc
  # ref: https://kubernetes.io/docs/reference/kubectl/jsonpath/
  # jsonpath is picky about string vs comparison quoting, so may need to
  # disable SC2026 for these lines. SC2086 allows for multiple args.

  # shellcheck disable=SC2026,SC2086
  pending_pods=$(kubectl get pods ${KUBECTL_ARGS} -o=jsonpath='{range .items[?(@.status.phase=="Pending")]}{.metadata.name}{"\n"}{end}')
  # check for empty string before counting lines, echo adds a newline
  if [ -z "$pending_pods" ]; then
    pending_pod_count=0
  else
    pending_pod_count=$( echo "$pending_pods" | wc -l)
  fi

  # shellcheck disable=SC2026,SC2086
  unready_containers=$(kubectl get pods ${KUBECTL_ARGS} -o=jsonpath='{range .items[?(@.status.phase=="Running")]}{range .status.containerStatuses[?(@.ready==false)]}{.name}: {.ready}{"\n"}{end}{end}')
  if [ -z "$unready_containers" ]; then
    unready_container_count=0
  else
    unready_container_count=$(echo "$unready_containers" | wc -l)
  fi

  # shellcheck disable=SC2026,SC2086
  active_jobs=$(kubectl get jobs $KUBECTL_ARGS -o=jsonpath='{range .items[?(@.status.active=='1')]}{.metadata.name}{"\n"}{end}')
  if [ -z "$active_jobs" ]; then
    active_job_count=0
  else
    active_job_count=$(echo "$active_jobs" | wc -l)
  fi

  total_unready=$((pending_pod_count + unready_container_count + active_job_count))

  # if everything is ready, print runtime and break
  if [ "$total_unready" -eq 0 ]
  then
    runtime=$((NOW - START_TIME))
    echo ""
    echo "All pods ready in $runtime seconds"
    break
  fi

  # deal with changes in number of jobs
  if [ "$total_unready" -ne "$prev_total_unready" ]
  then
    echo ""
    echo "Change in unready pods - Pending Pods: $pending_pod_count, Unready Containers: $unready_container_count, Active Jobs: $active_job_count"
  fi
  prev_total_unready=$total_unready

  # print number of unready pods every $CHECK_INTERVAL
  echo -n "$total_unready "
  sleep "$CHECK_INTERVAL"
done

exit ${fail_wfp}
