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
{{- define "mcord.fixtureTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/deployment.yaml
  - custom_types/site.yaml
  - custom_types/networktemplate.yaml
  - custom_types/network.yaml
  - custom_types/networkslice.yaml
  - custom_types/sitedeployment.yaml

description: set up site and deployment and link them

topology_template:
  node_templates:

    {{ .Values.cordSiteName }}:
      type: tosca.nodes.Site
      properties:
          name: {{ .Values.cordSiteName }}
          site_url: http://mysite.opencord.us/
          hosts_nodes: true

    {{ .Values.cordDeploymentName }}:
      type: tosca.nodes.Deployment
      properties:
        name: {{ .Values.cordDeploymentName }}
{{- end -}}

{{- define "mcord.serviceGraphTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/progranservice.yaml
   - custom_types/vepcservice.yaml
   - custom_types/servicegraphconstraint.yaml
   - custom_types/servicedependency.yaml
   - custom_types/serviceinstancelink.yaml

description: Configures the base-kubernetes service graph

topology_template:
  node_templates:
    service#vepcservice:
      type: tosca.nodes.VEpcService
      properties:
        name: vepc
        must-exist: true
    service#progran:
      type: tosca.nodes.ProgranService
      properties:
        name: progran
        must-exist: true
    service#mcord:
      type: tosca.nodes.MCordSubscriberService
      properties:
        name: mcord
{{- end -}}
