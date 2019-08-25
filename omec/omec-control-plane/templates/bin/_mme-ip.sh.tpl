#!/bin/bash
#
# Copyright 2019-present Open Networking Foundation
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

set -x

# Check if mme IP has been changed
kubectl get cm -n $NAMESPACE -o json mme-ip > mme-ip.json
mme_ip=$(jq '.data.IP' mme-ip.json)
if [ $mme_ip != null ] && [ $mme_ip = \"$POD_IP\" ]; then
    return
fi

# Update mme IP if it has been changed
cat <<EOF >patch.json
{"data": {"IP": "$POD_IP"}}
EOF
kubectl patch -n $NAMESPACE configmap mme-ip --patch "$(cat patch.json)"

# Update and restart SPGWC if it is deployed
kubectl get po -n $NAMESPACE --selector app=spgwc | grep Running -q
if [ $? -eq 0 ]; then
    kubectl rollout restart -n $NAMESPACE statefulset/spgwc
fi
