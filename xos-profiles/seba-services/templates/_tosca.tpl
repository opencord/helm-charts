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
{{- define "seba-services.onosTosca" }}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/onosapp.yaml
   - custom_types/onosservice.yaml
   - custom_types/serviceinstanceattribute.yaml

description: Configures the VOLTHA ONOS service

topology_template:
  node_templates:

    service#onos:
      type: tosca.nodes.ONOSService
      properties:
          name: onos
          kind: data
          rest_hostname: {{ .onosRestService | quote }}
          rest_port: 8181

    onos_app#openflow-base:
      type: tosca.nodes.ONOSApp
      properties:
        name: openflow-base
        app_id: org.onosproject.openflow-base
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

    onos_app#hostprovider:
      type: tosca.nodes.ONOSApp
      properties:
        name: hostprovider
        app_id: org.onosproject.hostprovider
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

    onos_app#olt:
      type: tosca.nodes.ONOSApp
      properties:
        name: olt
        app_id: org.opencord.olt
        url: {{ .oltAppUrl }}
        version: {{ .oltAppVersion }}
        dependencies: org.opencord.sadis
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

    onos_app#sadis:
      type: tosca.nodes.ONOSApp
      properties:
        name: sadis
        app_id: org.opencord.sadis
        url: {{ .sadisAppUrl }}
        version: {{ .sadisAppVersion }}
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

    onos_app#kafka:
      type: tosca.nodes.ONOSApp
      properties:
        name: kafka
        app_id: org.opencord.kafka
        url: {{ .kafkaAppUrl }}
        version: {{ .kafkaAppVersion }}
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

    # CORD-Configuration
    kafka-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/network/configuration/apps/org.opencord.kafka
        value: >
          {
            "kafka" : {
              "bootstrapServers" : {{ .kafkaService | quote }}
            }
          }
      requirements:
        - service_instance:
            node: onos_app#kafka
            relationship: tosca.relationships.BelongsToOne

    sadis-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/network/configuration/apps/org.opencord.sadis
        value: >
          {
            "sadis" : {
              "integration" : {
                "cache" : {
                  "maxsize" : 1000,
                  "ttl": "PT300S"
                },
                "url" : "http://sadis-service:8000/subscriber/%s"
              }
            },
            "bandwidthprofile":{
               "integration":{
                  "url": "http://sadis-service:8000/bandwidthprofiles/%s",
                  "cache":{
                     "enabled":true,
                     "maxsize":40,
                     "ttl":"PT1m"
                  }
               }
            }
          }
      requirements:
        - service_instance:
            node: onos_app#sadis
            relationship: tosca.relationships.BelongsToOne

    onos_app#segmentrouting:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.segmentrouting
        app_id: org.onosproject.segmentrouting
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

{{- if .fabric.stratum.enabled }}
    onos_app#stratum-driver:
      type: tosca.nodes.ONOSApp
      properties:
        name: {{ .fabric.stratum.driverAppId }}
        app_id: {{ .fabric.stratum.driverAppId }}
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne
    onos_app#fabric-pipeconf:
      type: tosca.nodes.ONOSApp
      properties:
        name: {{ .fabric.stratum.pipeconfAppId }}
        app_id: {{ .fabric.stratum.pipeconfAppId }}
{{- if .fabric.stratum.pipeconfAppExternal }}
        url: {{ .fabric.stratum.pipeconfAppUrl }}
        version: {{ .fabric.stratum.pipeconfAppVersion }}
{{- end }}
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne
{{- end }}

{{- if .bng.embedded.enabled }}
    onos_app#bng:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.opencord.bng
        app_id: org.opencord.bng
        url: {{ .bngAppUrl }}
        version: {{ .bngAppVersion }}
        dependencies: {{ .fabric.stratum.pipeconfAppId }}, org.opencord.kafka, org.opencord.sadis
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne
{{- end }}

    onos_app#netcfghostprovider:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.netcfghostprovider
        app_id: org.onosproject.netcfghostprovider
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

    onos_app#openflow:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.openflow
        app_id: org.onosproject.openflow
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne
{{- end }}

{{- define "seba-services.basicFixturesTosca" }}
tosca_definitions_version: tosca_simple_yaml_1_0
description: Some basic fixtures
imports:
  - custom_types/networkparametertype.yaml
  - custom_types/networktemplate.yaml
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

{{- end }}


{{- define "seba-services.serviceGraphTosca" }}
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/fabricservice.yaml
  - custom_types/onosservice.yaml
  - custom_types/rcordservice.yaml
  - custom_types/voltservice.yaml
{{- if .bng.external.enabled }}
  - custom_types/fabriccrossconnectservice.yaml
{{- end }}
{{- if .bng.embedded.enabled }}
  - custom_types/vrouterservice.yaml
{{- end }}
  - custom_types/servicedependency.yaml
  - custom_types/servicegraphconstraint.yaml
description: seba service graph
topology_template:
  node_templates:

# These services must be defined before loading the graph

    service#onos:
      type: tosca.nodes.ONOSService
      properties:
        name: onos
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

    service_dependency#onos-fabric_fabric:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#fabric
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#onos
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

    service_dependency#onos_volt:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#volt
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

    service_dependency#onos_rcord:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#rcord
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

{{- if .bng.external.enabled }}
    service#fabric-crossconnect:
      type: tosca.nodes.FabricCrossconnectService
      properties:
        name: fabric-crossconnect
        must-exist: true

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

    service_dependency#onos_fabric-crossconnect:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#fabric-crossconnect
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne
{{- end }}

{{- if .bng.embedded.enabled }}
    service#vrouter:
      type: tosca.nodes.VRouterService
      properties:
        name: vrouter
        must-exist: true

    service_dependency#fabric_vrouter:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#vrouter
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#fabric
            relationship: tosca.relationships.BelongsToOne
{{- end }}

{{- end }}
