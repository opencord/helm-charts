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
{{- define "internetemulator.serviceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/internetemulatorservice.yaml
  - custom_types/image.yaml

description: Configures the internetemulator service

topology_template:
  node_templates:

    service#internetemulator:
      type: tosca.nodes.InternetEmulatorService
      properties:
        name: internetemulator
        public_key: {{ .publicKey | quote }}
        private_key_fn: /opt/xos/services/internetemulator/keys/id_rsa

    image_internetemulator:
      type: tosca.nodes.Image
      properties:
        name: image_internetemulator_{{ .vnfImageVersion }}
        disk_format: QCOW2
        container_format: BARE
        path: {{ .vnfImageURL }}
{{- end -}}
