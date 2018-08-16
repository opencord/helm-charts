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
{{- define "rcord-lite.basicFixturesTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
description: Some basic fixtures
imports:
  - custom_types/siterole.yaml
  - custom_types/deployment.yaml
topology_template:
  node_templates:

# ----------------------------------------------------------------------------
# Roles
# ----------------------------------------------------------------------------
    siterole#admin:
      type: tosca.nodes.SiteRole
      properties:
        role: admin
    siterole#pi:
      type: tosca.nodes.SiteRole
      properties:
        role: pi
    siterole#tech:
      type: tosca.nodes.SiteRole
      properties:
        role: tech

# -----------------------------------------------------------------------------
# Deployment
# -----------------------------------------------------------------------------
    MyDeployment:
      type: tosca.nodes.Deployment
      properties:
        name: MyDeployment
{{- end -}}


{{- define "rcord-lite.serviceGraphTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/fabricservice.yaml
  - custom_types/onosservice.yaml
  - custom_types/rcordservice.yaml
  - custom_types/vrouterservice.yaml
  - custom_types/voltservice.yaml
  - custom_types/vsghwservice.yaml
  - custom_types/servicedependency.yaml
  - custom_types/servicegraphconstraint.yaml
description: rcord-lite service graph
topology_template:
  node_templates:

# These services must be defined before loading the graph

    service#ONOS_Fabric:
      type: tosca.nodes.ONOSService
      properties:
        name: ONOS_Fabric
        must-exist: true

    service#ONOS_VOLTHA:
      type: tosca.nodes.ONOSService
      properties:
        name: ONOS_VOLTHA
        must-exist: true

    service#fabric:
      type: tosca.nodes.FabricService
      properties:
        name: fabric
        must-exist: true

    service#rcord:
      type: tosca.nodes.RCORDService
      properties:
        name: rcord
        must-exist: true

    service#vrouter:
      type: tosca.nodes.VRouterService
      properties:
        name: vrouter
        must-exist: true

    service#volt:
      type: tosca.nodes.VOLTService
      properties:
        name: volt
        must-exist: true

    service#vsg-hw:
      type: tosca.nodes.VSGHWService
      properties:
        name: vsg-hw
        must-exist: true

# The rcord-lite service graph

    service_dependency#onos-fabric_fabric:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#fabric
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#ONOS_Fabric
            relationship: tosca.relationships.BelongsToOne

    service_dependency#rcord_volt:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#rcord
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne

    service_dependency#onos_voltha_volt:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#ONOS_VOLTHA
            relationship: tosca.relationships.BelongsToOne

    service_dependency#fabric_vrouter:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#fabric
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#vrouter
            relationship: tosca.relationships.BelongsToOne

    service_dependency#volt_vsg-hw:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#vsg-hw
            relationship: tosca.relationships.BelongsToOne

    service_dependency#onos_fabric_vsg-hw:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#vsg-hw
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#ONOS_Fabric
            relationship: tosca.relationships.BelongsToOne

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '[[null, "rcord"], ["ONOS_VOLTHA", "volt"], ["ONOS_Fabric", "vsg-hw"], ["fabric", null], ["vrouter", null]]'
{{- end -}}

