#!/bin/bash

{{/*
Copyright 2019-present Open Networking Foundation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

LTE_IF=oip1

function load_module() {
  mod_name=${1##*/}
  mod_name=${mod_name%.*}
  if awk "/$mod_name/ {found=1 ;exit} END {if (found!=1) exit 1}" /mnt/host-rootfs/proc/modules; then \
      echo "module $mod_name already loaded: remove it first"
      chroot /mnt/host-rootfs rmmod $mod_name
  fi
  echo loading $mod_name
  chroot /mnt/host-rootfs insmod $1
}

cp /openairinterface5g/targets/bin/ue_ip.ko /mnt/host-rootfs/tmp/ue_ip.ko
load_module /tmp/ue_ip.ko
