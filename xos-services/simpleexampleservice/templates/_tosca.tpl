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
{{- define "simpleexampleservice.serviceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/image.yaml
  - custom_types/site.yaml
  - custom_types/simpleexampleservice.yaml
  - custom_types/slice.yaml
  - custom_types/trustdomain.yaml

description: Configures the simple example service

topology_template:
  node_templates:

    default_trustdomain:
      type: tosca.nodes.TrustDomain
      properties:
        name: "default"
        must-exist: true

    httpd_image:
      type: tosca.nodes.Image
      properties:
        name: "httpd"
        tag: "2.4"

    service#simpleexampleservice:
      type: tosca.nodes.SimpleExampleService
      properties:
        name: simpleexampleservice
        service_message: hello
    mysite:
      type: tosca.nodes.Site
      properties:
        name: "mysite"
        must-exist: true
    simpleexampleservice_slice:
      type: tosca.nodes.Slice
      properties:
        name: "mysite_simpleexampleservice"
      requirements:
        - site:
            node: mysite
            relationship: tosca.relationships.BelongsToOne
        - trust_domain:
            node: default_trustdomain
            relationship: tosca.relationships.BelongsToOne
        - default_image:
            node: httpd_image
            relationship: tosca.relationships.BelongsToOne
        - service:
            node: service#simpleexampleservice
            relationship: tosca.relationships.BelongsToOne
{{- end -}}
