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
{{- define "hssdb.serviceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/hssdbservice.yaml
  - custom_types/hssdbvendor.yaml
  - custom_types/flavor.yaml
  - custom_types/image.yaml

description: Configures the HSSDB service

topology_template:
  node_templates:

    service#hssdb:
      type: tosca.nodes.HSSDBService
      properties:
        name: hssdb
        public_key: {{ .publicKey | quote }}
        private_key_fn: /opt/xos/services/hssdb/keys/id_rsa

    sprint_hssdb:
      type: tosca.nodes.HSSDBVendor
      properties:
        name: sprint_hssdb_{{ .vnfImageVersion }}
      requirements:
        - image:
            node: image_hssdb
            relationship: tosca.relationships.BelongsToOne
        - flavor:
            node: {{ .vnfImageFlavor }}
            relationship: tosca.relationships.BelongsToOne

    image_hssdb:
      type: tosca.nodes.Image
      properties:
        name: image_hssdb_{{ .vnfImageVersion }}
        disk_format: QCOW2
        container_format: BARE
        path: {{ .vnfImageURL }}

    {{ .vnfImageFlavor }}:
      type: tosca.nodes.Flavor
      properties:
        name: {{ .vnfImageFlavor }}
{{- end -}}
