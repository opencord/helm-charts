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
{{- define "openstack.flavorTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/flavor.yaml

description: openstack flavor models

topology_template:
  node_templates:

    m1.tiny:
      type: tosca.nodes.Flavor
      properties:
        name: m1.tiny
        flavor: m1.tiny

    m1.small:
      type: tosca.nodes.Flavor
      properties:
        name: m1.small
        flavor: m1.small

    m1.medium:
      type: tosca.nodes.Flavor
      properties:
        name: m1.medium
        flavor: m1.medium

    m1.large:
      type: tosca.nodes.Flavor
      properties:
        name: m1.large
        flavor: m1.large

    m1.xlarge:
      type: tosca.nodes.Flavor
      properties:
        name: m1.xlarge
        flavor: m1.xlarge
{{- end -}}

{{- define "openstack.networkTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/network.yaml
  - custom_types/networktemplate.yaml
  - custom_types/site.yaml
  - custom_types/slice.yaml

description: openstack flavor models

topology_template:
  node_templates:

    {{ .cordSiteName }}:
      type: tosca.nodes.Site
      properties:
        name: {{ .cordSiteName }}
        must-exist: true

# For private networks (e.g., per-slice)
    private_template:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: Private
        visibility: private
        translation: none
        vtn_kind: PRIVATE

# management (vtn: MANAGEMENT_LOCAL) network
    management_template:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: management_template
        visibility: private
        translation: none
        vtn_kind: MANAGEMENT_LOCAL

    management:
      type: tosca.nodes.Network
      properties:
        name: management
        # ip_version: 4
        subnet: 172.27.0.0/24
        permit_all_slices: true
      requirements:
        - template:
            node: management_template
            relationship: tosca.relationships.BelongsToOne
        - owner:
            node: slice#{{ .cordSiteName }}_management
            relationship: tosca.relationships.BelongsToOne

# Slice to own management networks
    slice#{{ .cordSiteName }}_management:
      description: This slice exists solely to own the management network(s)
      type: tosca.nodes.Slice
      properties:
        network: noauto
        name: {{ .cordSiteName }}_management
      requirements:
        - site:
            node: {{ .cordSiteName }}
            relationship: tosca.relationships.BelongsToOne
{{- end -}}

{{- define "openstack.controllerTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/controller.yaml
  - custom_types/controllersite.yaml
  - custom_types/deployment.yaml
  - custom_types/site.yaml
  - custom_types/sitedeployment.yaml
  - custom_types/openstackservice.yaml

description: openstack controller models

topology_template:
  node_templates:

    {{ .cordSiteName }}:
      type: tosca.nodes.Site
      properties:
          name: {{ .cordSiteName }}
          must-exist: true

    service#openstack:
      type: tosca.nodes.OpenStackService
      properties:
          name: "OpenStack"
          auth_url: http://keystone.openstack.svc.cluster.local/v3
          admin_user: {{ .keystoneAdminUser }}
          admin_password: {{ .keystoneAdminPassword }}
          admin_tenant: {{ .keystoneAdminTenant }}

    # TODO: deal with the lack of controller objects
    # TODO: All of this probably ends up in OpenStack service after the refactor
#    {{ .cordSiteName }}_somedeployment_openstack:
#      type: tosca.nodes.Controller
#      properties:
#          name: {{ .cordSiteName }}_somedeployment_openstack
#          backend_type: OpenStack
#          version: Newton
#          auth_url: http://keystone.openstack.svc.cluster.local/v3
#          admin_user: {{ .keystoneAdminUser }}
#          admin_password: {{ .keystoneAdminPassword }}
#          admin_tenant: {{ .keystoneAdminTenant }}
#          domain: {{ .keystoneDomain }}

{{- end -}}
