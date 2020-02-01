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
{{- define "onos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "onos.fullname" -}}
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
{{- define "onos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "onos.logCfg" -}}
################################################################################
#
#    Licensed to the Apache Software Foundation (ASF) under one or more
#    contributor license agreements.  See the NOTICE file distributed with
#    this work for additional information regarding copyright ownership.
#    The ASF licenses this file to You under the Apache License, Version 2.0
#    (the "License"); you may not use this file except in compliance with
#    the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
################################################################################

# Colors for log level rendering
color.fatal = bright red
color.error = bright red
color.warn = bright yellow
color.info = bright green
color.debug = cyan
color.trace = cyan

# Common pattern layout for appenders
log4j2.pattern = %d{ISO8601} | %-5p | %-16t | %-32c{1} | %X{bundle.id} - %X{bundle.name} - %X{bundle.version} | %m%n
log4j2.out.pattern = \u001b[90m%d{HH:mm:ss\.SSS}\u001b[0m %highlight{%-5level}{FATAL=${color.fatal}, ERROR=${color.error}, WARN=${color.warn}, INFO=${color.info}, DEBUG=${color.debug}, TRACE=${color.trace}} \u001b[90m[%c{1}]\u001b[0m %msg%n%throwable

# Root logger configuration
log4j2.rootLogger.level = INFO
# uncomment to use asynchronous loggers, which require mvn:com.lmax/disruptor/3.3.2 library
#log4j2.rootLogger.type = asyncRoot
#log4j2.rootLogger.includeLocation = false
log4j2.rootLogger.appenderRef.RollingFile.ref = RollingFile
log4j2.rootLogger.appenderRef.Kafka.ref = Kafka
log4j2.rootLogger.appenderRef.PaxOsgi.ref = PaxOsgi
log4j2.rootLogger.appenderRef.Console.ref = Console
log4j2.rootLogger.appenderRef.Console.filter.regex.type = RegexFilter
log4j2.rootLogger.appenderRef.Console.filter.regex.regex = .*Audit.*
log4j2.rootLogger.appenderRef.Console.filter.regex.onMatch = DENY
log4j2.rootLogger.appenderRef.Console.filter.regex.onMismatch = ACCEPT
#log4j2.rootLogger.appenderRef.Console.filter.threshold.type = ThresholdFilter
#log4j2.rootLogger.appenderRef.Console.filter.threshold.level = ${karaf.log.console:-OFF}

# Specific Loggers configuration

## SSHD logger
log4j2.logger.sshd.name = org.apache.sshd
log4j2.logger.sshd.level = INFO

## Spifly logger
log4j2.logger.spifly.name = org.apache.aries.spifly
log4j2.logger.spifly.level = WARN

## Kafka logger to avoid recursive logging
log4j2.logger.apacheKafka.name = org.apache.kafka
log4j2.logger.apacheKafka.level = INFO

# Appenders configuration

## Console appender not used by default (see log4j2.rootLogger.appenderRefs)
log4j2.appender.console.type = Console
log4j2.appender.console.name = Console
log4j2.appender.console.layout.type = PatternLayout
log4j2.appender.console.layout.pattern = ${log4j2.out.pattern}

## Rolling file appender
log4j2.appender.rolling.type = RollingRandomAccessFile
log4j2.appender.rolling.name = RollingFile
log4j2.appender.rolling.filter.regex.type = RegexFilter
log4j2.appender.rolling.filter.regex.regex = .*AuditLog.*
log4j2.appender.rolling.filter.regex.onMatch = DENY
log4j2.appender.rolling.filter.regex.onMismatch = ACCEPT
log4j2.appender.rolling.fileName = ${karaf.data}/log/karaf.log
log4j2.appender.rolling.filePattern = ${karaf.data}/log/karaf.log.%i
# uncomment to not force a disk flush
#log4j2.appender.rolling.immediateFlush = false
log4j2.appender.rolling.append = true
log4j2.appender.rolling.layout.type = PatternLayout
log4j2.appender.rolling.layout.pattern = ${log4j2.pattern}
log4j2.appender.rolling.rolling.type = DefaultRolloverStrategy
log4j2.appender.rolling.rolling.max = 10
log4j2.appender.rolling.policies.type = Policies
log4j2.appender.rolling.policies.size.type = SizeBasedTriggeringPolicy
log4j2.appender.rolling.policies.size.size = 10MB

## OSGi appender
log4j2.appender.osgi.type = PaxOsgi
log4j2.appender.osgi.name = PaxOsgi
log4j2.appender.osgi.filter = *

## Kafka appender
log4j2.appender.kafka.type = Kafka
log4j2.appender.kafka.name = Kafka
log4j2.appender.kafka.property.type = Property
log4j2.appender.kafka.property.name = bootstrap.servers
log4j2.appender.kafka.property.value = {{- join "," .Values.kafka_logging.brokers }}
log4j2.appender.kafka.topic = onos.log
# Async send, no need to wait for Kafka ack for each record
log4j2.appender.kafka.syncSend = false
log4j2.kafka.pattern = {"@timestamp":"%d{yyyy-MM-dd'T'HH:mm:ss.SSS'Z'}","levelname":"%p","threadName":"%t","category":"%c{1}","bundle.id":"%X{bundle.id}","bundle.name":"%X{bundle.name}","bundle.version":"%X{bundle.version}","message":"%m"}%n
log4j2.appender.kafka.layout.type = PatternLayout
log4j2.appender.kafka.layout.pattern = ${log4j2.kafka.pattern}

# Application logs
{{ .Values.application_logs }}

{{- end -}}

{{/*
Render a Service.
*/}}
{{- define "onos.service" -}}
{{- $name := index . 0 -}}
{{- $spec := index . 1 -}}
{{- $context := index . 2 -}}
{{- $namespace := $context.Release.Namespace }}
{{- $serviceName := printf "%s-%s" (include "onos.fullname" $context) $name }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $serviceName }}
  namespace: {{ $namespace }}
  labels:
    app: {{ template "onos.name" $context }}
    chart: {{ template "onos.chart" $context }}
    release: {{ $context.Release.Name }}
    heritage: {{ $context.Release.Service }}
spec:
  type: {{ $spec.type }}
  ports:
  - name: {{ $name }}
    port: {{ $spec.port }}
{{- if and $spec.type (eq (printf "%s" $spec.type) "NodePort") }}
    nodePort: {{ $spec.nodePort }}
{{- end }}
  selector:
    app: {{ template "onos.name" $context }}
    release: {{ $context.Release.Name }}
{{- end -}}
