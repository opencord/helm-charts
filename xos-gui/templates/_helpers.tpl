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

{{- define "xos-gui.release_labels" }}
app: {{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
version: {{ .Chart.Version }}
{{- end }}

{{- define "xos-gui.app_config" }}
angular.module('app')
.constant('AppConfig', {
  apiEndpoint: '/xosapi/v1',
  websocketClient: '/'
});
{{- end }}

{{- define "xos-gui.style_config" }}
angular.module('app')
.constant('StyleConfig', {
  projectName: {{ .Values.xos_projectName | quote }},
  favicon: 'cord-favicon.png',
  background: 'cord-bg.jpg',
  payoff: {{ .Values.xos_payoff | quote }},
  logo: 'cord-logo.png',
  routes: [
      {
          label: 'Slices',
          state: 'xos.core.slice',
      },
      {
          label: 'Nodes',
          state: 'xos.core.node',
      },
      {
          label: 'Instances',
          state: 'xos.core.instance',
      },
  ]
});
{{- end }}

{{- define "xos-gui.cord_version" }}
{
    "version": {{ .Values.cord_version | quote }}
}
{{- end }}
