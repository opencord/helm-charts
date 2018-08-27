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
{{- define "vepcservice.serviceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/image.yaml
  - custom_types/site.yaml
  - custom_types/vepcservice.yaml
  - custom_types/slice.yaml
  - custom_types/trustdomain.yaml

description: Configures the virtual EPC service

topology_template:
  node_templates:

    default_trustdomain:
      type: tosca.nodes.TrustDomain
      properties:
        name: "default"
        must-exist: true

    service#vepcservice:
      type: tosca.nodes.VEpcService
      properties:
        name: vepcservice
        service_message: hello
    mysite:
      type: tosca.nodes.Site
      properties:
        name: "mysite"
        must-exist: true
    
    vepcservice_slice_mme:
      type: tosca.nodes.Slice
      properties:
        name: "mysite_vepcservice_mme"
      requirements:
        - site:
            node: mysite
            relationship: tosca.relationships.BelongsToOne
        - trust_domain:
            node: default_trustdomain
            relationship: tosca.relationships.BelongsToOne
        - service:
            node: service#vepcservice
            relationship: tosca.relationships.BelongsToOne
    
    vepcservice_slice_hss:
      type: tosca.nodes.Slice
      properties:
        name: "mysite_vepcservice_hss"
      requirements:
        - site:
            node: mysite
            relationship: tosca.relationships.BelongsToOne
        - trust_domain:
            node: default_trustdomain
            relationship: tosca.relationships.BelongsToOne
        - service:
            node: service#vepcservice
            relationship: tosca.relationships.BelongsToOne


    vepcservice_slice_hssdb:
      type: tosca.nodes.Slice
      properties:
        name: "mysite_vepcservice_hssdb"
      requirements:
        - site:
            node: mysite
            relationship: tosca.relationships.BelongsToOne
        - trust_domain:
            node: default_trustdomain
            relationship: tosca.relationships.BelongsToOne
        - service:
            node: service#vepcservice
            relationship: tosca.relationships.BelongsToOne

    vepcservice_slice_spgwc:
      type: tosca.nodes.Slice
      properties:
        name: "mysite_vepcservice_spgwc"
      requirements:
        - site:
            node: mysite
            relationship: tosca.relationships.BelongsToOne
        - trust_domain:
            node: default_trustdomain
            relationship: tosca.relationships.BelongsToOne
        - service:
            node: service#vepcservice
            relationship: tosca.relationships.BelongsToOne

    vepcserviceinstance:
      type: tosca.nodes.VEpcServiceInstance
      properties:
        name: "EPC for Compute"
      requirements:
        - owner:
            node: service#vepcservice
            relationship: tosca.relationships.BelongsToOne

    vepcimage_mme:
      type: tosca.nodes.VEpcImage
      properties:
        component_name: "MME"
        image_name: "ngick8stesting/c3po-mme"
        image_tag: "5e2eaf6"
      requirements:
        - serviceinstance:
            node: vepcserviceinstance
            relationship: tosca.relationships.BelongsToOne

    vepcimage_hss:
      type: tosca.nodes.VEpcImage
      properties:
        component_name: "HSS"
        image_name: "ngick8stesting/c3po-hss"
        image_tag: "5e2eaf6"
      requirements:
        - serviceinstance:
            node: vepcserviceinstance
            relationship: tosca.relationships.BelongsToOne

    vepcimage_hssdb:
      type: tosca.nodes.VEpcImage
      properties:
        component_name: "hssdb"
        image_name: "ngick8stesting/c3po-cassandra"
        image_tag: "5e2eaf6"
      requirements:
        - serviceinstance:
            node: vepcserviceinstance
            relationship: tosca.relationships.BelongsToOne

    vepcimage_spgwc:
      type: tosca.nodes.VEpcImage
      properties:
        component_name: "spgwc"
        image_name: "ngick8stesting/ngic-cp"
        image_tag: "d9b315c"
      requirements:
        - serviceinstance:
            node: vepcserviceinstance
            relationship: tosca.relationships.BelongsToOne
{{- end -}}
