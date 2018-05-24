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
{{- define "mcord.fixtureTosca" -}}
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

{{- define "mcord.serviceGraphTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/internetemulatorservice.yaml
   - custom_types/hssdbservice.yaml
   - custom_types/mcordsubscriberservice.yaml
   - custom_types/progranservice.yaml
   - custom_types/sdncontrollerservice.yaml
   - custom_types/vepcservice.yaml
   - custom_types/vhssservice.yaml
   - custom_types/vmmeservice.yaml
   - custom_types/vspgwcservice.yaml
   - custom_types/vspgwuservice.yaml
   - custom_types/servicegraphconstraint.yaml
   - custom_types/servicedependency.yaml
   - custom_types/serviceinstancelink.yaml

description: Configures the base-openstack service graph

topology_template:
  node_templates:

    service#vmme:
      type: tosca.nodes.VMMEService
      properties:
        name: vmme
        must-exist: true

    service#vspgwc:
      type: tosca.nodes.VSPGWCService
      properties:
        name: vspgwc
        must-exist: true

    service#vspgwu:
      type: tosca.nodes.VSPGWUService
      properties:
        name: vspgwu
        must-exist: true

    service#vhss:
      type: tosca.nodes.VHSSService
      properties:
        name: vhss
        must-exist: true

    service#hssdb:
      type: tosca.nodes.HSSDBService
      properties:
        name: hssdb
        must-exist: true

    service#internetemulator:
      type: tosca.nodes.InternetEmulatorService
      properties:
        name: internetemulator
        must-exist: true

    service#sdncontroller:
      type: tosca.nodes.SDNControllerService
      properties:
        name: sdncontroller
        must-exist: true

    service#vepc:
      type: tosca.nodes.VEPCService
      properties:
        name: vepc
        must-exist: true

    service#progran:
      type: tosca.nodes.ProgranService
      properties:
        name: progran
        must-exist: true

    service#mcord:
      type: tosca.nodes.MCordSubscriberService
      properties:
        name: mcord

    vmme_vspgwc:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#vmme
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#vspgwc
            relationship: tosca.relationships.BelongsToOne

    vmme_vspgwu:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#vmme
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#vspgwu
            relationship: tosca.relationships.BelongsToOne

    vspgwc_vspgwu:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#vspgwc
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#vspgwu
            relationship: tosca.relationships.BelongsToOne

    vmme_vhss:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#vmme
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#vhss
            relationship: tosca.relationships.BelongsToOne

    vhss_hssdb:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#vhss
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#hssdb
            relationship: tosca.relationships.BelongsToOne

    mcord_vmme:
      type: tosca.nodes.ServiceDependency
      properties:
        connect_method: None
      requirements:
        - subscriber_service:
            node: service#vmme
            relationship: tosca.relationships.BelongsToOne
        - provider_service:
            node: service#mcord
            relationship: tosca.relationships.BelongsToOne

    constraints:
      type: tosca.nodes.ServiceGraphConstraint
      properties:
        constraints: '[ ["vepc", null, "mcord", null, null], [null, null, "progran", null, null], ["hssdb", "vhss", "vmme", null, null], [null, "vspgwc", "sdncontroller","vspgwu", null], [null, null, null, "internetemulator", null] ]'
{{- end -}}

{{- define "mcord.sliceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/internetemulatorservice.yaml
   - custom_types/hssdbservice.yaml
   - custom_types/mcordsubscriberservice.yaml
   - custom_types/progranservice.yaml
   - custom_types/sdncontrollerservice.yaml
   - custom_types/vepcservice.yaml
   - custom_types/vhssservice.yaml
   - custom_types/vmmeservice.yaml
   - custom_types/vspgwcservice.yaml
   - custom_types/vspgwuservice.yaml
   - custom_types/servicegraphconstraint.yaml
   - custom_types/servicedependency.yaml
   - custom_types/serviceinstancelink.yaml
   - custom_types/site.yaml
   - custom_types/slice.yaml
   - custom_types/flavor.yaml
   - custom_types/image.yaml

description: Configures the M-CORD slices

topology_template:
  node_templates:

    {{ .Values.cordSiteName }}:
      type: tosca.nodes.Site
      properties:
        name: {{ .Values.cordSiteName }}
        must-exist: true

    service#vmme:
      type: tosca.nodes.VMMEService
      properties:
        name: vmme
        must-exist: true

    service#vspgwc:
      type: tosca.nodes.VSPGWCService
      properties:
        name: vspgwc
        must-exist: true

    service#vspgwu:
      type: tosca.nodes.VSPGWUService
      properties:
        name: vspgwu
        must-exist: true

    service#vhss:
      type: tosca.nodes.VHSSService
      properties:
        name: vhss
        must-exist: true

    service#hssdb:
      type: tosca.nodes.HSSDBService
      properties:
        name: hssdb
        must-exist: true

    service#internetemulator:
      type: tosca.nodes.InternetEmulatorService
      properties:
        name: internetemulator
        must-exist: true

    service#sdncontroller:
      type: tosca.nodes.SDNControllerService
      properties:
        name: sdncontroller
        must-exist: true

    m1.small:
      type: tosca.nodes.Flavor
      properties:
        name: m1.small
        must-exist: true

    m1.large:
      type: tosca.nodes.Flavor
      properties:
        name: m1.large
        must-exist: true

    m1.xlarge:
      type: tosca.nodes.Flavor
      properties:
        name: m1.xlarge
        must-exist: true

    image_mme:
      type: tosca.nodes.Image
      properties:
        name: image_mme_{{ .Values.vmme.vnfImageVersion }}
        must-exist: true

    image_spgwc:
      type: tosca.nodes.Image
      properties:
        name: image_spgwc_{{ .Values.vspgwc.vnfImageVersion }}
        must-exist: true

    image_spgwu:
      type: tosca.nodes.Image
      properties:
        name: image_spgwu_{{ .Values.vspgwu.vnfImageVersion }}
        must-exist: true

    image_hss:
      type: tosca.nodes.Image
      properties:
        name: image_hss_{{ .Values.vhss.vnfImageVersion }}
        must-exist: true

    image_hssdb:
      type: tosca.nodes.Image
      properties:
        name: image_hssdb_{{ .Values.hssdb.vnfImageVersion }}
        must-exist: true

    image_internetemulator:
      type: tosca.nodes.Image
      properties:
        name: image_internetemulator_{{ .Values.internetemulator.vnfImageVersion }}
        must-exist: true

    image_sdncontroller:
      type: tosca.nodes.Image
      properties:
        name: image_sdncontroller_{{ .Values.sdncontroller.vnfImageVersion }}
        must-exist: true

    {{ .Values.cordSiteName }}_vmme:
      description: vMME Service Slice
      type: tosca.nodes.Slice
      properties:
          name: {{ .Values.cordSiteName }}_vmme
          default_isolation: vm
          network: noauto
      requirements:
          - site:
              node: {{ .Values.cordSiteName }}
              relationship: tosca.relationships.BelongsToOne
          - service:
              node: service#vmme
              relationship: tosca.relationships.BelongsToOne
          - default_image:
              node: image_mme
              relationship: tosca.relationships.BelongsToOne
          - default_flavor:
              node: m1.large
              relationship: tosca.relationships.BelongsToOne

    {{ .Values.cordSiteName }}_vspgwc:
      description: vSPGW-C slice
      type: tosca.nodes.Slice
      properties:
          name: {{ .Values.cordSiteName }}_vspgwc
          default_isolation: vm
          network: noauto
      requirements:
          - site:
              node: {{ .Values.cordSiteName }}
              relationship: tosca.relationships.BelongsToOne
          - service:
              node: service#vspgwc
              relationship: tosca.relationships.BelongsToOne
          - default_image:
              node: image_spgwc
              relationship: tosca.relationships.BelongsToOne
          - default_flavor:
              node: m1.large
              relationship: tosca.relationships.BelongsToOne

    {{ .Values.cordSiteName }}_vspgwu:
      description: vSPGW-U slice
      type: tosca.nodes.Slice
      properties:
          name: {{ .Values.cordSiteName }}_vspgwu
          default_isolation: vm
          network: noauto
      requirements:
          - site:
              node: {{ .Values.cordSiteName }}
              relationship: tosca.relationships.BelongsToOne
          - service:
              node: service#vspgwu
              relationship: tosca.relationships.BelongsToOne
          - default_image:
              node: image_spgwu
              relationship: tosca.relationships.BelongsToOne
          - default_flavor:
              node: m1.xlarge
              relationship: tosca.relationships.BelongsToOne

    {{ .Values.cordSiteName }}_vhss:
      description: vHSS Service Slice
      type: tosca.nodes.Slice
      properties:
          name: {{ .Values.cordSiteName }}_vhss
          default_isolation: vm
          network: noauto
      requirements:
          - site:
              node: {{ .Values.cordSiteName }}
              relationship: tosca.relationships.BelongsToOne
          - service:
              node: service#vhss
              relationship: tosca.relationships.BelongsToOne
          - default_image:
              node: image_hss
              relationship: tosca.relationships.BelongsToOne
          - default_flavor:
              node: m1.large
              relationship: tosca.relationships.BelongsToOne

    {{ .Values.cordSiteName }}_hssdb:
      description: HSS-DB Service Slice
      type: tosca.nodes.Slice
      properties:
          name: {{ .Values.cordSiteName }}_hssdb
          default_isolation: vm
          network: noauto
      requirements:
          - site:
              node: {{ .Values.cordSiteName }}
              relationship: tosca.relationships.BelongsToOne
          - service:
              node: service#hssdb
              relationship: tosca.relationships.BelongsToOne
          - default_image:
              node: image_hssdb
              relationship: tosca.relationships.BelongsToOne
          - default_flavor:
              node: m1.large
              relationship: tosca.relationships.BelongsToOne

    {{ .Values.cordSiteName }}_internetemulator:
      description: Internetemulator Service Slice
      type: tosca.nodes.Slice
      properties:
          name: {{ .Values.cordSiteName }}_internetemulator
          default_isolation: vm
          network: noauto
      requirements:
          - site:
              node: {{ .Values.cordSiteName }}
              relationship: tosca.relationships.BelongsToOne
          - service:
              node: service#internetemulator
              relationship: tosca.relationships.BelongsToOne
          - default_image:
              node: image_internetemulator
              relationship: tosca.relationships.BelongsToOne
          - default_flavor:
              node: m1.small
              relationship: tosca.relationships.BelongsToOne

    {{ .Values.cordSiteName }}_sdncontroller:
      description: SDN controller slice
      type: tosca.nodes.Slice
      properties:
          name: {{ .Values.cordSiteName }}_sdncontroller
          default_isolation: vm
          network: noauto
      requirements:
          - site:
              node: {{ .Values.cordSiteName }}
              relationship: tosca.relationships.BelongsToOne
          - service:
              node: service#sdncontroller
              relationship: tosca.relationships.BelongsToOne
          - default_image:
              node: image_sdncontroller
              relationship: tosca.relationships.BelongsToOne
          - default_flavor:
              node: m1.small
              relationship: tosca.relationships.BelongsToOne
{{- end -}}

{{- define "mcord.networkTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/networktemplate.yaml
   - custom_types/slice.yaml
   - custom_types/networkslice.yaml
   - custom_types/network.yaml

description: Configures the M-CORD network templates, vEPC will create the networks

topology_template:
  node_templates:

    private_template:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: private_template
        visibility: private
        translation: none
        vtn_kind: PRIVATE

    flat_template:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: flat_template
        visibility: private
        translation: none
        vtn_kind: FLAT

# Network Slices for InternetEmulator, not created by EPC

    management:
      type: tosca.nodes.Network
      properties:
        name: management
        must-exist: true

    {{ .Values.cordSiteName }}_internetemulator:
      type: tosca.nodes.Slice
      properties:
        name: {{ .Values.cordSiteName }}_internetemulator
        must-exist: true

    {{ .Values.cordSiteName }}_vspgwu:
      type: tosca.nodes.Slice
      properties:
        name: {{ .Values.cordSiteName }}_vspgwu
        must-exist: true

    sgi_network:
      type: tosca.nodes.Network
      properties:
          name: sgi_network
          subnet: 115.0.0.0/24
          permit_all_slices: true
      requirements:
          - template:
              node: private_template
              relationship: tosca.relationships.BelongsToOne
          - owner:
              node: {{ .Values.cordSiteName }}_vspgwu
              relationship: tosca.relationships.BelongsToOne

    internetemulator_slice_management_network:
      type: tosca.nodes.NetworkSlice
      requirements:
        - network:
            node: management
            relationship: tosca.relationships.BelongsToOne
        - slice:
            node: {{ .Values.cordSiteName }}_internetemulator
            relationship: tosca.relationships.BelongsToOne

    internetemulator_slice_sgi_network:
      type: tosca.nodes.NetworkSlice
      requirements:
        - network:
            node: sgi_network
            relationship: tosca.relationships.BelongsToOne
        - slice:
            node: {{ .Values.cordSiteName }}_internetemulator
            relationship: tosca.relationships.BelongsToOne

{{- end -}}
