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
{{- define "att-workflow.basicFixturesTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
description: Some basic fixtures
imports:
  - custom_types/deployment.yaml
  - custom_types/networkparametertype.yaml
  - custom_types/networktemplate.yaml
  - custom_types/siterole.yaml
topology_template:
  node_templates:

# -----------------------------------------------------------------------------
# Network Parameter Types
# -----------------------------------------------------------------------------
    s_tag:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: s_tag
    c_tag:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: c_tag
    next_hop:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: next_hop
    device:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: device
    bridge:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: bridge
    neutron_port_name:
      type: tosca.nodes.NetworkParameterType
      properties:
        name: neutron_port_name

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
# Network Templates
# -----------------------------------------------------------------------------
    Private:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: Private
        visibility: private
        translation: none

    Public shared IPv4:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: Public shared IPv4
        visibility: private
        translation: NAT
        shared_network_name: nat-net

    Public dedicated IPv4:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: Public dedicated IPv4
        visibility: public
        translation: none
        shared_network_name: ext-net

# -----------------------------------------------------------------------------
# Deployment
# -----------------------------------------------------------------------------
    MyDeployment:
      type: tosca.nodes.Deployment
      properties:
        name: MyDeployment
{{- end -}}


{{- define "att-workflow.serviceGraphTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/attworkflowdriverservice.yaml
  - custom_types/fabricservice.yaml
  - custom_types/onosservice.yaml
  - custom_types/rcordservice.yaml
  - custom_types/voltservice.yaml
  - custom_types/fabriccrossconnectservice.yaml
  - custom_types/servicedependency.yaml
  - custom_types/servicegraphconstraint.yaml
description: att-workflow service graph
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

    service#volt:
      type: tosca.nodes.VOLTService
      properties:
        name: volt
        must-exist: true

    service#fabric-crossconnect:
      type: tosca.nodes.FabricCrossconnectService
      properties:
        name: fabric-crossconnect
        must-exist: true

    service#att-workflow-driver:
      type: tosca.nodes.AttWorkflowDriverService
      properties:
        name: att-workflow-driver
        must-exist: true

# The att-workflow service graph

    service_dependency#onos-fabric_fabric:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#ONOS_Fabric
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#fabric
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

    service_dependency#volt_fabric-crossconnect:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#fabric-crossconnect
            relationship: tosca.relationships.BelongsToOne

    service_dependency#onos_fabric_fabric-crossconnect:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#fabric-crossconnect
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#ONOS_Fabric
            relationship: tosca.relationships.BelongsToOne

    service_dependency#workflow_volt:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#att-workflow-driver
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '[[null, "rcord", null], ["ONOS_VOLTHA", "volt", null], ["ONOS_Fabric", "fabric-crossconnect", "att-workflow-driver"], ["fabric", null, null]]'
{{- end -}}

