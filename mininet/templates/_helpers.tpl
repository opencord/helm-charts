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

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mininet.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mininet.fullname" -}}
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
{{- define "mininet.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate the CNI annotations depending on number of OLTs
*/}}
{{- define "mininet.cni" -}}
{{- printf "calico" -}}
{{- range $i, $junk := until (.Values.numOlts|int) -}}
{{- printf ",nni%d" $i -}}
{{- end -}}
{{- end -}}

{{/*
Generate the DHCP subnets depending on number of OLTs
*/}}
{{- define "mininet.dhcp_range" -}}
{{- $onucount := .Values.numOnus|int}}
{{- range $i, $junk := until (.Values.numOlts|int) -}}
{{- range $j, $junk1 := until ($onucount) -}}
{{- printf " --dhcp-range=172.%d.%d.50,172.%d.%d.150,12h" (add $i 18) $j (add $i 18) $j -}}
{{- end -}}
{{- end -}}
{{- end -}}
