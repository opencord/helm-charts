
{{- /*
 Copyright 2017-present Open Networking Foundation

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */ -}}

 {{- define "sriov_webserver.name" -}}
 {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
 {{- end -}}

{{- define "sriov_webserver.release_labels" }}
app: {{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 }}
version: {{ .Chart.Version }}
release: {{ .Release.Name }}
{{- end }}
{{- define "sriov_webserver.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sriov_webserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
