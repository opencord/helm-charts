{{- /*
# Copyright 2018-present Open Networking Foundation
# Copyright 2018 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
*/ -}}

{{/*
Renders a set of standardised labels
*/}}
{{- define "omec-control-plane.metadata_labels" -}}
{{- $application := index . 0 -}}
{{- $context := index . 1 -}}
release: {{ $context.Release.Name }}
app: {{ $application }}
{{- end -}}

{{/*
Render the given template.
*/}}
{{- define "omec-control-plane.template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $last := base $context.Template.Name }}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{/*
Return identity, realm, and hostname of the first pod of the given statefulset.
*/}}
{{- define "omec-control-plane.endpoint_lookup" -}}
{{- $service := index . 0 -}}
{{- $type := index . 1 -}}
{{- $context := index . 2 -}}
{{- if eq $type "identity" -}}
{{- printf "%s-0.%s.%s.svc.%s" $service $service $context.Release.Namespace "cluster.local" -}}
{{- else if eq $type "realm" -}}
{{- printf "%s.%s.svc.%s" $service $context.Release.Namespace "cluster.local" -}}
{{- else if eq $type "host" -}}
{{- printf "%s-0" $service -}}
{{- end -}}
{{- end -}}
