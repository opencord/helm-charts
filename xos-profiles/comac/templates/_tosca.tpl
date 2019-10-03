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

{{- define "comac.onosTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/onosapp.yaml
   - custom_types/onosservice.yaml
   - custom_types/serviceinstanceattribute.yaml

description: Configures services in COMAC

topology_template:
  node_templates:

    service#onos:
      type: tosca.nodes.ONOSService
      properties:
          name: onos
          kind: data
          rest_hostname: {{ .onosRestService | quote }}
          rest_port: 8181

{{- if $.residentialService.enabled }}
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

    # FOR ATT-Workflow --
    onos_app#aaa:
      type: tosca.nodes.ONOSApp
      properties:
        name: aaa
        app_id: org.opencord.aaa
        url: {{ .aaaAppUrl }}
        version: {{ .aaaAppVersion }}
        dependencies: org.opencord.sadis
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne
    # --

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

    onos_app#dhcpl2relay:
      type: tosca.nodes.ONOSApp
      properties:
        name: dhcpl2relay
        app_id: org.opencord.dhcpl2relay
        url: {{ .dhcpl2relayAppUrl }}
        version: {{ .dhcpl2relayAppVersion }}
        dependencies: org.opencord.sadis
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

    # FOR ATT-Workflow --
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
    # --
{{- end }}

    onos_app#segmentrouting:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.segmentrouting
        app_id: org.onosproject.segmentrouting
      requirements:
        - owner:
            node: service#onos
            relationship: tosca.relationships.BelongsToOne

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
{{- end -}}

{{- define "comac.basicFixturesTosca" -}}
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

{{- end -}}

{{- define "comac.serviceGraphTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/fabricservice.yaml
  - custom_types/mcordsubscriberservice.yaml
  - custom_types/onosservice.yaml
  - custom_types/vrouterservice.yaml
{{- if .Values.progran.enabled }}
  - custom_types/progranservice.yaml
{{- end }}
{{- if .Values.residentialService.enabled }}
  - custom_types/rcordservice.yaml
  - custom_types/voltservice.yaml
  - custom_types/fabriccrossconnectservice.yaml
  - custom_types/attworkflowdriverservice.yaml
{{- end }}
  - custom_types/servicegraphconstraint.yaml
  - custom_types/servicedependency.yaml
  - custom_types/service.yaml
description: COMAC service graph
topology_template:
  node_templates:

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

    service#vrouter:
      type: tosca.nodes.VRouterService
      properties:
        name: vrouter
        must-exist: true

    service#mcord:
      type: tosca.nodes.MCordSubscriberService
      properties:
        name: mcord
        must-exist: true

{{ if .Values.progran.enabled }}
    service#progran:
      type: tosca.nodes.ProgranService
      properties:
        name: progran
        must-exist: true
{{ end }}

{{- if .Values.residentialService.enabled }}
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

    # FOR ATT-Workflow --
    service#att-workflow-driver:
      type: tosca.nodes.AttWorkflowDriverService
      properties:
        name: att-workflow-driver
        must-exist: true
    # --
{{- end }}

    service#omec-cp:
      type: tosca.nodes.Service
      properties:
        name: omec-cp

    service#omec-up:
      type: tosca.nodes.Service
      properties:
        name: omec-up

    service#cdn-local:
      type: tosca.nodes.Service
      properties:
        name: cdn-local

    service#cdn-remote:
      type: tosca.nodes.Service
      properties:
        name: cdn-remote

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

    service_dependency#vrouter_fabric:
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

{{- if .Values.residentialService.enabled }}
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

    # FOR ATT-Workflow --
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
    # --
{{- end }}

{{ if .Values.progran.enabled }}
    service_dependency#mcord_progran:
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

    service_dependency#progran_epc_cp:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#omec-cp
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#progran
            relationship: tosca.relationships.BelongsToOne

    service_dependency#progran_epc_up:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#omec-up
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#progran
            relationship: tosca.relationships.BelongsToOne

{{ else }}
    service_dependency#mcord_epc_cp:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#omec-cp
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#mcord
            relationship: tosca.relationships.BelongsToOne

    service_dependency#mcord_epc_up:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#omec-up
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#mcord
            relationship: tosca.relationships.BelongsToOne
{{ end }}

    service_dependency#epc_cp_epc_up:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#omec-up
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#omec-cp
            relationship: tosca.relationships.BelongsToOne

    service_dependency#epc_up_cdn_local:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#cdn-local
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#omec-up
            relationship: tosca.relationships.BelongsToOne

    service_dependency#cdn_local_cdn_remote:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#cdn-remote
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#cdn-local
            relationship: tosca.relationships.BelongsToOne

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '[["mcord", null, null, "rcord"], ["progran", null, "att-workflow-driver", "volt"], ["omec-cp", "omec-up", "onos", "fabric-crossconnect"], [null, "cdn-local", "fabric", null], [null, "cdn-remote", "vrouter", null]]'
{{- end -}}
