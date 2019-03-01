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

{{- define "rcord-lite.onosTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/onosapp.yaml
  - custom_types/onosservice.yaml
  - custom_types/serviceinstanceattribute.yaml
description: ONOS service and app for fabric
topology_template:
  node_templates:
    service#ONOS:
      type: tosca.nodes.ONOSService
      properties:
          name: ONOS
          kind: data
          rest_hostname: {{ .onosRestService | quote }}
          rest_port: 8181

    onos_app#segmentrouting:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.segmentrouting
        app_id: org.onosproject.segmentrouting
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#vrouter:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.vrouter
        app_id: org.onosproject.vrouter
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#netcfghostprovider:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.netcfghostprovider
        app_id: org.onosproject.netcfghostprovider
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#openflow:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.openflow
        app_id: org.onosproject.openflow
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#openflow-base:
      type: tosca.nodes.ONOSApp
      properties:
        name: openflow-base
        app_id: org.onosproject.openflow-base
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#hostprovider:
      type: tosca.nodes.ONOSApp
      properties:
        name: hostprovider
        app_id: org.onosproject.hostprovider
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#cord-config:
      type: tosca.nodes.ONOSApp
      properties:
        name: cord-config
        app_id: org.opencord.config
        url: {{ .cordConfigAppURL }}
        version: 1.4.0
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#olt:
      type: tosca.nodes.ONOSApp
      properties:
        name: olt
        app_id: org.opencord.olt
        url: {{ .oltAppUrl }}
        version: 2.0.0.SNAPSHOT
        dependencies: org.opencord.config
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#sadis:
      type: tosca.nodes.ONOSApp
      properties:
        name: sadis
        app_id: org.opencord.sadis
        url: {{ .sadisAppUrl }}
        version: 2.1.0
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#dhcpl2relay:
      type: tosca.nodes.ONOSApp
      properties:
        name: dhcpl2relay
        app_id: org.opencord.dhcpl2relay
        url: {{ .dhcpl2relayAppUrl }}
        version: 1.5.0.SNAPSHOT
        dependencies: org.opencord.sadis
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#aaa:
      type: tosca.nodes.ONOSApp
      properties:
        name: aaa
        app_id: org.opencord.aaa
        url: {{ .aaaAppUrl }}
        version: 1.8.0.SNAPSHOT
        dependencies: org.opencord.sadis
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    onos_app#kafka:
      type: tosca.nodes.ONOSApp
      properties:
        name: kafka
        app_id: org.opencord.kafka
        url: {{ .kafkaAppUrl }}
        version: 1.0.0.SNAPSHOT
        dependencies: org.opencord.olt,org.opencord.aaa,org.opencord.dhcpl2relay
      requirements:
        - owner:
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    # CORD-Configuration
    cord-config-attr:
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
            node: onos_app#olt
            relationship: tosca.relationships.BelongsToOne

    olt-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/configuration/org.opencord.olt.impl.Olt?preset=true
        value: >
          {
            "enableDhcpOnProvisioning" : true
          }
      requirements:
        - service_instance:
            node: onos_app#olt
            relationship: tosca.relationships.BelongsToOne

    dhcpl2relay-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/network/configuration/apps/org.opencord.dhcpl2relay
        value: >
          {
            "dhcpl2relay" : {
              "useOltUplinkForServerPktInOut" : true
            }
          }
      requirements:
        - service_instance:
            node: onos_app#dhcpl2relay
            relationship: tosca.relationships.BelongsToOne

    aaa-config-attr:
      type: tosca.nodes.ServiceInstanceAttribute
      properties:
        name: /onos/v1/network/configuration/apps/org.opencord.aaa
        value: >
          {
            "AAA" : {
              "radiusConnectionType" : "socket",
              "radiusHost" : "freeradius.voltha.svc.cluster.local",
              "radiusServerPort" : "1812",
              "radiusSecret" : "SECRET"
            }
          }
      requirements:
        - service_instance:
            node: onos_app#aaa
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
                  "maxsize" : 1000
                },
                "url" : "http://sadis-service:8000/subscriber/%s"
              }
            }
          }
      requirements:
        - service_instance:
            node: onos_app#sadis
            relationship: tosca.relationships.BelongsToOne
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

    service#ONOS:
      type: tosca.nodes.ONOSService
      properties:
        name: ONOS
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
            node: service#ONOS
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
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

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
            node: service#ONOS
            relationship: tosca.relationships.BelongsToOne

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '[[null, "rcord"], [null, "volt"], ["ONOS", "vsg-hw"], ["fabric", null], ["vrouter", null]]'
{{- end -}}
