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
{{- define "vspgwu.serviceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/vspgwuservice.yaml
  - custom_types/vspgwuvendor.yaml
  - custom_types/flavor.yaml
  - custom_types/image.yaml

description: Configures the vSPGWU service

topology_template:
  node_templates:

    service#vspgwu:
      type: tosca.nodes.VSPGWUService
      properties:
        name: vspgwu
        public_key: {{ .publicKey | quote }}
        private_key_fn: /opt/xos/services/vspgwu/keys/id_rsa

    intel_vspgwu:
      type: tosca.nodes.VSPGWUVendor
      properties:
        name: intel_vspgwu_{{ .vnfImageVersion }}
      requirements:
        - image:
            node: image_spgwu
            relationship: tosca.relationships.BelongsToOne
        - flavor:
            node: {{ .vnfImageFlavor }}
            relationship: tosca.relationships.BelongsToOne

    image_spgwu:
      type: tosca.nodes.Image
      properties:
        name: image_spgwu_{{ .vnfImageVersion }}
        disk_format: QCOW2
        container_format: BARE
        path: {{ .vnfImageURL }}

    {{ .vnfImageFlavor }}:
      type: tosca.nodes.Flavor
      properties:
        name: {{ .vnfImageFlavor }}
{{- end -}}
