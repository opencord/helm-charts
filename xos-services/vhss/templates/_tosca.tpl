{{/* vim: set filetype=mustache: */}}
{{/*
Copyright 2018-present Open Networking Foundation

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
{{- define "vhss.serviceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/vhssservice.yaml
  - custom_types/vhssvendor.yaml
  - custom_types/flavor.yaml
  - custom_types/image.yaml

description: Configures the vHSS service

topology_template:
  node_templates:

    service#vhss:
      type: tosca.nodes.VHSSService
      properties:
        name: vhss
        public_key: {{ .publicKey | quote }}
        private_key_fn: /opt/xos/services/vhss/keys/id_rsa

    sprint_hss:
      type: tosca.nodes.VHSSVendor
      properties:
        name: sprint_hss_{{ .vnfImageVersion }}
      requirements:
        - image:
            node: image_hss
            relationship: tosca.relationships.BelongsToOne
        - flavor:
            node: {{ .vnfImageFlavor }}
            relationship: tosca.relationships.BelongsToOne

    image_hss:
      type: tosca.nodes.Image
      properties:
        name: image_hss_{{ .vnfImageVersion }}
        disk_format: QCOW2
        container_format: BARE
        path: {{ .vnfImageURL }}

    {{ .vnfImageFlavor }}:
      type: tosca.nodes.Flavor
      properties:
        name: {{ .vnfImageFlavor }}
{{- end -}}
