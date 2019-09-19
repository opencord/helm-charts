{{- /*
Copyright 2019-present Open Networking Foundation

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

{{/*
Renders a set of standardised labels
*/}}
{{- define "cdn-local.metadata_labels" -}}
{{- $application := index . 0 -}}
{{- $context := index . 1 -}}
release: {{ $context.Release.Name }}
app: {{ $application }}
{{- end -}}

{{/*
Render the given template.
*/}}
{{- define "cdn-local.template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $last := base $context.Template.Name }}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{/*
Render ServiceAccount, Role, and RoleBinding required for kubernetes-entrypoint.
*/}}
{{- define "cdn-local.service_account" -}}
{{- $saName := index . 0 -}}
{{- $context := index . 1 -}}
{{- $saNamespace := $context.Release.Namespace }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
  labels:
{{ tuple $saName $context | include "cdn-local.metadata_labels" | indent 4 }}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
  labels:
{{ tuple $saName $context | include "cdn-local.metadata_labels" | indent 4 }}
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
{{ tuple $saName $context | include "cdn-local.metadata_labels" | indent 4 }}
rules:
  - apiGroups:
      - ""
      - extensions
      - batch
      - apps
    verbs:
      - get
      - list
      - patch
    resources:
      - statefulsets
      - daemonsets
      - jobs
      - pods
      - services
      - endpoints
      - configmaps
{{- end -}}