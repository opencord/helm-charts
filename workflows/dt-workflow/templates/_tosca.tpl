{{/* vim: set filetype=mustache: */}}
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

{{- define "dt-workflow.serviceGraphTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/dtworkflowdriverservice.yaml
  - custom_types/voltservice.yaml
  - custom_types/servicedependency.yaml
  - custom_types/servicegraphconstraint.yaml
description: dt-workflow-driver service graph
topology_template:
  node_templates:

# These services must be defined before loading the graph

    service#volt:
      type: tosca.nodes.VOLTService
      properties:
        name: volt
        must-exist: true

    service#dt-workflow-driver:
      type: tosca.nodes.DtWorkflowDriverService
      properties:
        name: dt-workflow-driver
        must-exist: true

    service_dependency#workflow_volt:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#dt-workflow-driver
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '[[null, "rcord", null], [null, "volt", null], ["onos", "vrouter", "dt-workflow-driver"], ["fabric", null, null]]'
{{- end -}}

{{- define "dt-workflow.onosTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/onosapp.yaml
   - custom_types/onosservice.yaml
   - custom_types/serviceinstanceattribute.yaml

description: Configures workflow-specific ONOS apps

topology_template:
  node_templates:

    service#onos:
      type: tosca.nodes.ONOSService
      properties:
          name: onos
          must-exist: true

    onos_app#olt:
      type: tosca.nodes.ONOSApp
      properties:
        name: olt
        must-exist: true

    olt-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/configuration/org.opencord.olt.impl.Olt?preset=true
        value: >
          {
            "enableDhcpOnProvisioning" : false
          }
      requirements:
        - service_instance:
            node: onos_app#olt
            relationship: tosca.relationships.BelongsToOne
{{- end -}}
