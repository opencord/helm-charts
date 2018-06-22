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
{{- define "demo-exampleservice.publicNetworkTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0
description: Setup public network
imports:
  - custom_types/networktemplate.yaml
  - custom_types/network.yaml
  - custom_types/site.yaml
  - custom_types/slice.yaml
topology_template:
  node_templates:
    mysite:
      type: tosca.nodes.Site
      properties:
        name: {{ .Values.cordSiteName }}
        must-exist: true

    public_networking_slice:
      description: This slice exists solely to own the public network
      type: tosca.nodes.Slice
      properties:
        network: noauto
        name: public_networking
      requirements:
        - site:
            node: mysite
            relationship: tosca.relationships.BelongsToOne

    # public network
    public_template:
      type: tosca.nodes.NetworkTemplate
      properties:
        name: public_template
        visibility: public
        translation: none
        vtn_kind: PUBLIC

    public:
      type: tosca.nodes.Network
      properties:
        name: public
        permit_all_slices: true
        subnet: {{ .Values.addresspool_public_cidr }}
        # ip_version: 4
      requirements:
        - template:
            node: public_template
            relationship: tosca.relationships.BelongsToOne
        - owner:
            node: public_networking_slice
            relationship: tosca.relationships.BelongsToOne
{{- end -}}
