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
{{- define "vtn-service.serviceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/vtnservice.yaml

description: Configures the VTN ONOS service

topology_template:
  node_templates:

    service#vtn:
      type: tosca.nodes.VTNService
      properties:
          name: vtn
          kind: platform
          view_url: /admin/vtn/vtnservice/$id$/
          privateGatewayMac: 00:00:00:00:00:01
          localManagementIp: 172.27.0.1/24
          ovsdbPort: 6641
          sshUser: {{ .sshUser }}
          sshKeyFile: /root/vtn/node_key
          sshPort: {{ .sshPort }}
          xosEndpoint: xos-chameleon:9101
          xosUser: {{ .xosAdminUser }}
          xosPassword: {{ .xosAdminPassword }}
          vtnAPIVersion: 2
          controllerPort: onos-cord-openflow:6653
          resync: false
{{- end -}}
