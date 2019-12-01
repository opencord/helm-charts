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

{{- define "exporter.config" -}}
---
broker:
  name: broker-name
  host: {{ .Values.kpi_exporter.kpi_broker }}
  description: The kafka broker
  topics: {{ range .Values.kpi_exporter.topics }}
    - {{ . }} {{ end }}
logger:
  loglevel: info
  host: {{ .Values.kpi_exporter.kpi_broker }}
target:
  type: prometheus-target
  name: http-server
  port: 8080
  description: http target for prometheus
{{- end -}}

{{/*
Create a default fully qualified kpi-exporter name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "kpi-exporter.fullname" -}}
{{- if .Values.kpi_exporter.fullnameOverride -}}
{{- .Values.kpi_exporter.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "nem-kpi-exporter" .Values.kpi_exporter.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
