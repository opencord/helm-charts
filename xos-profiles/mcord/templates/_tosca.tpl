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
   - custom_types/mcordsubscriberservice.yaml
   - custom_types/progranservice.yaml
   - custom_types/servicegraphconstraint.yaml
   - custom_types/servicedependency.yaml

description: Configures the base-openstack service graph

topology_template:
  node_templates:

    service#progran:
      type: tosca.nodes.ProgranService
      properties:
        name: progran
        must-exist: true

    service#mcord:
      type: tosca.nodes.MCordSubscriberService
      properties:
        name: mcord
        must-exist: true

    mcord_progran:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#progran
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#mcord
            relationship: tosca.relationships.BelongsToOne

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '[ "mcord", "progran"]'
{{- end -}}

