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
{{- define "mcord-services.onosFabricTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
description: Configures ONOS services

imports:
   - custom_types/onosapp.yaml
   - custom_types/onosservice.yaml
   - custom_types/serviceinstanceattribute.yaml

topology_template:
  node_templates:

    service#onos:
      type: tosca.nodes.ONOSService
      properties:
          name: onos
          kind: data
          rest_hostname: {{ .onosFabricRestHost | quote }}
          rest_port: {{ .onosFabricRestPort }}

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

{{- define "mcord-services.onosProgranTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
description: Configures ONOS services

imports:
   - custom_types/onosapp.yaml
   - custom_types/onosservice.yaml
   - custom_types/serviceinstanceattribute.yaml

topology_template:
  node_templates:

    service#onos-progran:
      type: tosca.nodes.ONOSService
      properties:
          name: onos-progran
          kind: data
          rest_hostname: {{ .onosProgranRestHost | quote }}
          rest_port: {{ .onosProgranRestPort }}

    onos_app#progran:
      type: tosca.nodes.ONOSApp
      properties:
        name: org.onosproject.progran
        app_id: org.onosproject.progran
      requirements:
        - owner:
            node: service#onos-progran
            relationship: tosca.relationships.BelongsToOne
{{- end -}}

{{- define "mcord-services.serviceGraphTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/mcordsubscriberservice.yaml
   - custom_types/servicegraphconstraint.yaml
   - custom_types/servicedependency.yaml
   - custom_types/service.yaml
{{- if or .Values.fabric.enabled .Values.progran.enabled }}
   - custom_types/onosservice.yaml
{{- end }}
{{- if .Values.fabric.enabled }}
   - custom_types/fabricservice.yaml
   - custom_types/vrouterservice.yaml
{{- end }}
{{- if .Values.progran.enabled }}
   - custom_types/progranservice.yaml
{{- end }}

description: Configures the M-CORD service graph

topology_template:
  node_templates:
    service#mcord:
      type: tosca.nodes.MCordSubscriberService
      properties:
        name: mcord
        must-exist: true

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

{{- if .Values.fabric.enabled }}
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
{{- end }}

{{- if .Values.progran.enabled }}
    service#onos-progran:
      type: tosca.nodes.ONOSService
      properties:
        name: onos-progran
        must-exist: true

    service#progran:
      type: tosca.nodes.ProgranService
      properties:
        name: progran
        must-exist: true
{{- end }}

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

    service_dependency#cdn_remote_cdn_local:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#cdn-local
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#cdn-remote
            relationship: tosca.relationships.BelongsToOne

{{- if .Values.fabric.enabled }}
    service_dependency#fabric_vrouter:
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

    service_dependency#onos_fabric:
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

{{- if .Values.progran.enabled }}
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

    service_dependency#onos_progran:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: none
      requirements:
        - subscriber_service:
            node: service#progran
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#onos-progran
            relationship: tosca.relationships.BelongsToOne
{{- end }}

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
{{- if and .Values.fabric.enabled .Values.progran.enabled }}
        constraints: '[ [null, "mcord", null, "fabric"], ["cdn-remote", "omec-cp", "progran", "vrouter"], ["cdn-local", "omec-up", "onos-progran", "onos"] ]'
{{- else if and (not .Values.fabric.enabled) .Values.progran.enabled }}
        constraints: '[ [null, null, "mcord", null], ["cdn-remote", "omec-cp", null, "progran"], ["cdn-local", "omec-up", null, "onos-progran"] ]'
{{- else if and .Values.fabric.enabled (not .Values.progran.enabled) }}
        constraints: '[ [null, "mcord", "fabric"], ["cdn-remote", "omec-cp", "vrouter"], ["cdn-local", "omec-up", "onos"] ]'
{{- else }}
        constraints: '[ [null, "mcord"], ["cdn-remote", "omec-cp"], ["cdn-local", "omec-up"] ]'
{{- end }}
{{- end -}}
