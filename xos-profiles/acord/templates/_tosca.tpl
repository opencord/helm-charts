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

{{- define "acord.basicFixturesTosca" -}}
---
tosca_definitions_version: tosca_simple_yaml_1_0

description: Some basic fixtures

imports:
  - custom_types/deployment.yaml

topology_template:
  node_templates:

    MyDeployment:
      type: tosca.nodes.Deployment
      properties:
        name: MyDeployment

{{- end -}}

{{- define "acord.kafkaTosca" -}}
---
tosca_definitions_version: tosca_simple_yaml_1_0

description: Registration of Kafka endpoint

imports:
  - custom_types/collector.yaml

topology_template:
  node_templates:

    kafka:
      type: tosca.nodes.Collector
      properties:
        name: kafka
        collector_type: HTTP
        endpoint_url: 'http://10.0.0.1:9092'

{{- end -}}
