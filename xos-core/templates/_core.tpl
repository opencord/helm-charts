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

{{- define "xos-core.config" }}
name: xos-core
xos_dir: /opt/xos
kafka_bootstrap_servers:
  - {{ .Values.platformKafka }}
database:
  name: {{ .Values.xosDBName | quote }}
  username: {{ .Values.xosDBUser | quote }}
  password: {{ .Values.xosDBPassword | quote }}
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
    kafka:
      class: kafkaloghandler.KafkaLogHandler
      bootstrap_servers:
        - {{ .Values.platformKafka }}
      topic: xos.log.core
  loggers:
    '':
      handlers:
        - console
        - file
        - kafka
      level: {{ .Values.loglevel }}
{{- end }}

{{- define "xos-core.initial_data" }}
- model: core.Site
  fields:
    name: {{ .Values.cordSiteName | quote }}
    abbreviated_name: {{ .Values.cordSiteName | quote }}
    login_base: {{ .Values.cordSiteName | quote }}
    site_url: "http://opencord.org/"
    hosts_nodes: true

- model: core.User
  fields:
    email: {{ .Values.xosAdminUser | quote }}
    password: {{ .Values.xosAdminPassword | quote }}
    firstname: {{ .Values.xosAdminFirstname | quote }}
    lastname:  {{ .Values.xosAdminLastname | quote }}
    is_admin: true
  relations:
    site:
      fields:
        name: {{ .Values.cordSiteName | quote }}
      model: core.Site
{{- end }}

{{- define "xos-core.ca_cert_chain" }}
{{ (.Files.Get "pki/xos-CA.pem")}}
{{- end }}

