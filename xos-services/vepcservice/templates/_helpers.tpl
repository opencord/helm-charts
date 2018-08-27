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
{{/*
Expand the name of the chart.
*/}}
{{- define "vepcservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vepcservice.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vepcservice.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "vepcservice.serviceConfig" -}}
name: vepcservice
accessor:
  username: {{ .Values.xosAdminUser | quote }}
  password: {{ .Values.xosAdminPassword | quote }}
  endpoint: xos-core:50051
event_bus:
  endpoint: {{ .Values.kafkaService | quote }}
  kind: kafka
required_models:
  - VEpcService
  - VEpcServiceInstance
  - VEpcResourceInstanceLink
  - ServiceDependency
  - KubernetesService
  - KubernetesResourceInstance
dependency_graph: "/opt/xos/synchronizers/vepcservice/model-deps"
steps_dir: "/opt/xos/synchronizers/vepcservice/steps"
event_steps_dir: "/opt/xos/synchronizers/vepcservice/event_steps"
sys_dir: "/opt/xos/synchronizers/vepcservice/sys"
model_policies_dir: "/opt/xos/synchronizers/vepcservice/model_policies"
models_dir: "/opt/xos/synchronizers/vepcservice/models"
logging:
  version: 1
  handlers:
    console:
      class: logging.StreamHandler
    file:
      class: logging.handlers.RotatingFileHandler
      filename: /var/log/xos.log
      maxBytes: 10485760
      backupCount: 5
  loggers:
    'multistructlog':
      handlers:
          - console
          - file
      level: DEBUG
{{- end -}}
