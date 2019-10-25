{{- /*
# Copyright 2019-present Open Networking Foundation
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
Return endpoint of the given application.
*/}}
{{- define "oaisim.endpoint_lookup" -}}
{{- $app := index . 0 -}}
{{- $type := index . 1 -}}
{{- $context := index . 2 -}}
{{- $appContext := index $context.Values.config $app -}}
{{- $appName := $appContext.name -}}
{{- if eq $type "fqdn" -}}
{{- printf "%s-0.%s.%s.svc.%s" $appName $appName $context.Release.Namespace "cluster.local" -}}
{{- else if eq $type "short" -}}
{{- printf "%s-0.%s" $appName $appName -}}
{{- end -}}
{{- end -}}

{{/*
Render the given template.
*/}}
{{- define "oaisim.template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $last := base $context.Template.Name }}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{/*
Return PLMN from MCC and MNC.
*/}}
{{- define "oaisim.plmn" -}}
{{- $mcc := index . 0 -}}
{{- $mnc := index . 1 -}}
{{- printf "%s%s" $mcc $mnc -}}
{{- end -}}

{{/*
Renders a set of standardised labels
*/}}
{{- define "oaisim.metadata_labels" -}}
{{- $application := index . 0 -}}
{{- $context := index . 1 -}}
release: {{ $context.Release.Name }}
app: {{ $application }}
{{- end -}}

{{/*
Render ServiceAccount, Role, and RoleBinding required for kubernetes-entrypoint.
*/}}
{{- define "oaisim.service_account" -}}
{{- $context := index . 1 -}}
{{- $saName := index . 0 -}}
{{- $saNamespace := $context.Release.Namespace }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
  labels:
{{ tuple $saName $context | include "oaisim.metadata_labels" | indent 4 }}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
  labels:
{{ tuple $saName $context | include "oaisim.metadata_labels" | indent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ $saName }}
subjects:
  - kind: ServiceAccount
    name: {{ $saName }}
    namespace: {{ $saNamespace }}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
  labels:
{{ tuple $saName $context | include "oaisim.metadata_labels" | indent 4 }}
rules:
  - apiGroups:
      - ""
      - extensions
      - batch
      - apps
    verbs:
      - get
      - list
    resources:
      - statefulsets
      - jobs
      - pods
      - services
      - endpoints
      - configmaps
{{- end -}}
