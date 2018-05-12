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
{{- define "onos-service.fabricAppTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
imports:
  - custom_types/onosapp.yaml
  - custom_types/onosservice.yaml
description: ONOS service and app for fabric
topology_template:
  node_templates:
    service#ONOS_Fabric:
      type: tosca.nodes.ONOSService
      properties:
          name: ONOS_Fabric
          kind: platform
          no_container: true
          rest_hostname: onos-fabric-ui
          rest_port: 8181

    Fabric_ONOS_app:
      type: tosca.nodes.ONOSApp
      requirements:
          - owner:
              node: service#ONOS_Fabric
              relationship: tosca.relationships.BelongsToOne
      properties:
          name: Fabric_ONOS_app
          dependencies: org.onosproject.drivers, org.onosproject.openflow, org.onosproject.netcfghostprovider, org.onosproject.segmentrouting, org.onosproject.vrouter
{{- end -}}

{{- define "onos-service.vtnAppTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/onosapp.yaml
   - custom_types/onosservice.yaml
   - custom_types/serviceinstanceattribute.yaml

description: Configures the VTN ONOS service

topology_template:
  node_templates:

    service#ONOS_CORD:
      type: tosca.nodes.ONOSService
      properties:
          name: ONOS_CORD
          kind: platform
          no_container: true
          rest_hostname: onos-cord-ui
          rest_port: 8181

    VTN_ONOS_app:
      type: tosca.nodes.ONOSApp
      requirements:
          - owner:
              node: service#ONOS_CORD
              relationship: tosca.relationships.BelongsToOne
      properties:
          name: VTN_ONOS_app
          install_dependencies: https://repo.maven.apache.org/maven2/org/opencord/cord-config/1.3.1/cord-config-1.3.1.oar, https://repo.maven.apache.org/maven2/org/opencord/vtn/1.5.0/vtn-1.5.0.oar
          dependencies: org.onosproject.drivers, org.onosproject.drivers.ovsdb, org.onosproject.openflow-base, org.onosproject.ovsdb-base, org.onosproject.dhcp

    VTN_ONOS_app_autogenerate:
        type: tosca.nodes.ServiceInstanceAttribute
        requirements:
          - service_instance:
              node: VTN_ONOS_app
              relationship: tosca.relationships.BelongsToOne
        properties:
            name: autogenerate
            value: vtn-network-cfg
{{- end -}}
