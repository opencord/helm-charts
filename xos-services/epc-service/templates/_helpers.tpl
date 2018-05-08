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
{{- define "epc-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "epc-service.fullname" -}}
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
{{- define "epc-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "epc-service.serviceConfig" -}}
name: vepc
accessor:
  username: {{ .Values.xosAdminUser | quote }}
  password: {{ .Values.xosAdminPassword | quote }}
  endpoint: xos-core:50051
required_models:
  - VEPCService
  - VEPCServiceInstance
dependency_graph: "/opt/xos/synchronizers/epc-service/model-deps"
# steps_dir: "/opt/xos/synchronizers/epc-service/steps"
sys_dir: "/opt/xos/synchronizers/epc-service/sys"
model_policies_dir: "/opt/xos/synchronizers/epc-service/model_policies"
models_dir: "/opt/xos/synchronizers/epc-service/models"
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
blueprints:
  - name: build
    networks:
      - name: s1u_network
        subnet: 111.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vspgwu
      - name: s11_network
        subnet: 112.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vspgwc
      - name: sgi_network
        subnet: 115.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vspgwu
      - name: spgw_network
        subnet: 117.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vspgwu
    graph:
      - name: VSPGWUTenant
        networks:
          - management
          - s1u_network
          - sgi_network
          - spgw_network
        links:
          - name: VENBServiceInstance
            node_label: gwu-enb
            networks:
              - s1u_network
              - sgi_network
      - name: VENBServiceInstance
        networks:
          - management
          - s1u_network
          - sgi_network
          - s11_network
      - name: VSPGWCTenant
        networks:
          - management
          - s11_network
          - spgw_network
        links:
          - name: VENBServiceInstance
            networks:
              - s11_network
          - name: VSPGWUTenant
            networks:
              - spgw_network
  - name: mcord_5
    networks:
      - name: flat_network_s1u
        subnet: 119.0.0.0/24
        permit_all_slices: True
        template: flat_template
        owner: vspgwu
      - name: flat_network_s1mme
        subnet: 118.0.0.0/24
        permit_all_slices: True
        template: flat_template
        owner: vmme
      - name: s11_network
        subnet: 112.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vspgwc
      - name: sgi_network
        subnet: 115.0.0.0/24
        permit_all_slices: True
        owner: vspgwu
        template: private_template
      - name: spgw_network
        subnet: 117.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vspgwu
      - name: s6a_network
        subnet: 120.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vhss
      - name: db_network
        subnet: 121.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vhss
    graph:
      - name: VMMETenant
        networks:
          - management
          - flat_network_s1mme
          - s11_network
          - s6a_network
        links:
          - name: VHSSTenant
            networks:
              - s6a_network
      - name: VSPGWCTenant
        networks:
          - management
          - s11_network
          - spgw_network
        links:
          - name: VMMETenant
            networks:
              - s11_network
          - name: VSPGWUTenant
            networks:
              - spgw_network
      - name: VSPGWUTenant
        networks:
          - management
          - flat_network_s1u
          - sgi_network
          - spgw_network
      - name: VHSSTenant
        networks:
          - management
          - s6a_network
          - db_network
        links:
          - name: HSSDBServiceInstance
            networks:
              - db_network
      - name: HSSDBServiceInstance
        networks:
          - management
          - db_network
  - name: mcord_5_p4
    networks:
      - name: flat_network_s1mme
        subnet: 118.0.0.0/24
        permit_all_slices: True
        template: flat_template
        owner: vmme
      - name: s11_network
        subnet: 112.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vspgwc
      - name: s6a_network
        subnet: 120.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vhss
      - name: db_network
        subnet: 121.0.0.0/24
        permit_all_slices: True
        template: private_template
        owner: vhss
    graph:
      - name: VMMETenant
        networks:
          - management
          - flat_network_s1mme
          - s11_network
          - s6a_network
        links:
          - name: VHSSTenant
            networks:
              - s6a_network
      - name: VSPGWCTenant
        networks:
          - management
          - s11_network
        links:
          - name: VMMETenant
            networks:
              - s11_network
      - name: VHSSTenant
        networks:
          - management
          - s6a_network
          - db_network
        links:
          - name: HSSDBServiceInstance
            networks:
              - db_network
      - name: HSSDBServiceInstance
        networks:
          - management
          - db_network

{{- end -}}
