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
{{- define "base-openstack.fixtureTosca" -}}
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

{{- define "base-openstack.serviceGraphTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/onosapp.yaml
   - custom_types/servicegraphconstraint.yaml
   - custom_types/serviceinstancelink.yaml
   - custom_types/vtnservice.yaml

description: Configures the base-openstack service graph

topology_template:
  node_templates:

    service#vtn:
      type: tosca.nodes.VTNService
      properties:
        name: vtn
        must-exist: true
        resync: false

    VTN_ONOS_app:
      type: tosca.nodes.ONOSApp
      properties:
          name: VTN_ONOS_app
          must-exist: true

    VTN_ONOS_app_VTN_Service:
        type: tosca.nodes.ServiceInstanceLink
        requirements:
          - provider_service_instance:
              node: VTN_ONOS_app
              relationship: tosca.relationships.BelongsToOne
          - subscriber_service:
              node: service#vtn
              relationship: tosca.relationships.BelongsToOne
{{- end -}}

{{- define "base-openstack.testTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/flavor.yaml
  - custom_types/image.yaml
  - custom_types/site.yaml
  - custom_types/network.yaml
  - custom_types/networkslice.yaml
  - custom_types/slice.yaml

description: for testing basic openstack functionality

topology_template:
  node_templates:

    Ubuntu-14.04:
      type: tosca.nodes.Image
      properties:
        name: "Ubuntu 14.04 64-bit"
        disk_format: QCOW2
        container_format: BARE
        path: https://github.com/opencord/platform-install/releases/download/vms/trusty-server-cloudimg-amd64-disk1.img.20170201

    {{ .Values.cordSiteName }}:
      type: tosca.nodes.Site
      properties:
        name: {{ .Values.cordSiteName }}
        must-exist: true

# Define a test slice
    {{ .Values.cordSiteName }}_test:
      description: Test Slice
      type: tosca.nodes.Slice
      properties:
        # network: noauto
        name: {{ .Values.cordSiteName }}_test
      requirements:
        - site:
            node: {{ .Values.cordSiteName }}
            relationship: tosca.relationships.BelongsToOne
        - default_image:
            node: Ubuntu-14.04
            relationship: tosca.relationships.BelongsToOne

    management:
      type: tosca.nodes.Network
      properties:
        name: management
        must-exist: true

# Connect test slice to management net
    networkslice#management_to_{{ .Values.cordSiteName }}_test:
        type: tosca.nodes.NetworkSlice
        requirements:
          - network:
              node: management
              relationship: tosca.relationships.BelongsToOne
          - slice:
              node: {{ .Values.cordSiteName }}_test
              relationship: tosca.relationships.BelongsToOne
{{- end -}}

{{- define "base-openstack.computeNodeTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/deployment.yaml
  - custom_types/node.yaml
  - custom_types/site.yaml
  - custom_types/sitedeployment.yaml

description: Adds OpenStack compute nodes

topology_template:
  node_templates:

# Site/Deployment, fully defined in deployment.yaml
    site:
      type: tosca.nodes.Site
      properties:
        name: {{ .Values.cordSiteName }}
        must-exist: true

    deployment:
      type: tosca.nodes.Deployment
      properties:
        name: {{ .Values.cordDeploymentName }}
        must-exist: true

    site_deployment:
      type: tosca.nodes.SiteDeployment
      requirements:
        - site:
            node: site
            relationship: tosca.relationships.BelongsToOne
        - deployment:
            node: deployment
            relationship: tosca.relationships.BelongsToOne

# OpenStack compute nodes

    {{- range .Values.computeNodes }}
    {{ .name }}:
      type: tosca.nodes.Node
      properties:
        name: {{ .name }}
        bridgeId: {{ .bridgeId }}
        dataPlaneIntf: {{ .dataPlaneIntf }}
        dataPlaneIp: {{ .dataPlaneIp }}
      requirements:
        - site_deployment:
            node:  site_deployment
            relationship: tosca.relationships.BelongsToOne
    {{- end }}
{{- end -}}
