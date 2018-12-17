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

{{- define "xos-tosca.config" }}
name: xos-tosca
gprc_endpoint: "xos-core"
local_cert: /usr/local/share/ca-certificates/local_certs.crt
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
      topic: xos.log.tosca
  loggers:
    '':
      handlers:
        - console
        - file
        - kafka
      level: DEBUG
{{- end }}
