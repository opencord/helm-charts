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


{{- define "onos.startupKaraf" -}}
# Bundles to be started on startup, with startlevel
mvn\:org.apache.karaf.features/org.apache.karaf.features.extension/4.2.6 = 1
mvn\:org.apache.felix/org.apache.felix.metatype/1.2.2 = 5
mvn\:org.apache.karaf.services/org.apache.karaf.services.eventadmin/4.2.6 = 5
mvn\:org.ops4j.pax.url/pax-url-aether/2.6.1 = 5
mvn\:org.fusesource.jansi/jansi/1.18 = 8
mvn\:org.apache.servicemix.bundles/org.apache.servicemix.bundles.kafka-clients/0.8.2.2_1 = 6
mvn\:org.ops4j.pax.logging/pax-logging-log4j2-extra/1.11.4 = 7
mvn\:org.ops4j.pax.logging/pax-logging-api/1.11.4 = 8
mvn\:org.ops4j.pax.logging/pax-logging-log4j2/1.11.4 = 8
mvn\:org.apache.felix/org.apache.felix.coordinator/1.0.2 = 9
mvn\:org.apache.felix/org.apache.felix.configadmin/1.9.14 = 10
mvn\:org.apache.felix/org.apache.felix.fileinstall/3.6.4 = 11
mvn\:org.apache.karaf.features/org.apache.karaf.features.core/4.2.6 = 15
mvn\:org.apache.servicemix.specs/org.apache.servicemix.specs.activation-api-1.1/2.9.0 = 30
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
log4j2.kafka.patter = {"@timestamp":"%d{yyyy-MM-dd'T'HH:mm:ss.SSS'Z'}","levelname":"%p","threadName":"%t","category":"%c{1}","bundle.id":"%X{bundle.id}","bundle.name":"%X{bundle.name}","bundle.version":"%X{bundle.version}","message":"%m"}%n

# Root logger
log4j2.rootLogger.level = INFO
# uncomment to use asynchronous loggers, which require mvn:com.lmax/disruptor/3.3.2 library
#log4j2.rootLogger.type = asyncRoot
#log4j2.rootLogger.includeLocation = false
log4j2.rootLogger.appenderRef.RollingFile.ref = RollingFile
log4j2.rootLogger.appenderRef.AuditFile.ref = AuditFile
log4j2.rootLogger.appenderRef.PaxOsgi.ref = PaxOsgi
log4j2.rootLogger.appenderRef.Kafka.ref = Kafka
log4j2.rootLogger.appenderRef.Console.ref = Console
log4j2.rootLogger.appenderRef.Console.filter.regex.type = RegexFilter
log4j2.rootLogger.appenderRef.Console.filter.regex.regex = .*Audit.*
log4j2.rootLogger.appenderRef.Console.filter.regex.onMatch = DENY
log4j2.rootLogger.appenderRef.Console.filter.regex.onMisMatch = ACCEPT
#log4j2.rootLogger.appenderRef.Console.filter.threshold.type = ThresholdFilter
#log4j2.rootLogger.appenderRef.Console.filter.threshold.level = ${karaf.log.console:-OFF}

# Loggers configuration

# SSHD logger
log4j2.logger.sshd.name = org.apache.sshd
log4j2.logger.sshd.level = INFO

# Spifly logger
log4j2.logger.spifly.name = org.apache.aries.spifly
log4j2.logger.spifly.level = WARN



# Security audit logger
log4j2.logger.audit.name = audit
log4j2.logger.audit.level = TRACE
log4j2.logger.audit.additivity = false
log4j2.logger.audit.appenderRef.AuditRollingFile.ref = AuditRollingFile

log4j2.logger.securityAudit.name = securityAudit
log4j2.logger.securityAudit.level = TRACE
log4j2.logger.securityAudit.additivity = false
log4j2.logger.securityAudit.appenderRef.AuditRollingFile.ref = AuditRollingFile

log4j2.logger.karafAudit.name = karafAudit
log4j2.logger.karafAudit.level = TRACE
log4j2.logger.karafAudit.additivity = false
log4j2.logger.karafAudit.appenderRef.AuditRollingFile.ref = KarafRollingFile

# Appenders configuration

# Console appender not used by default (see log4j2.rootLogger.appenderRefs)
log4j2.appender.console.type = Console
log4j2.appender.console.name = Console
log4j2.appender.console.layout.type = PatternLayout
log4j2.appender.console.layout.pattern = ${log4j2.out.pattern}

# Rolling file appender
log4j2.appender.rolling.type = RollingRandomAccessFile
log4j2.appender.rolling.name = RollingFile
log4j2.appender.rolling.filter.regex.type = RegexFilter
log4j2.appender.rolling.filter.regex.regex = .*AuditLog.*
log4j2.appender.rolling.filter.regex.onMatch = DENY
log4j2.appender.rolling.filter.regex.onMisMatch = ACCEPT
log4j2.appender.rolling.fileName = ${karaf.data}/log/karaf.log
log4j2.appender.rolling.filePattern = ${karaf.data}/log/karaf.log.%i
# uncomment to not force a disk flush
#log4j2.appender.rolling.immediateFlush = false
log4j2.appender.rolling.append = true
log4j2.appender.rolling.layout.type = PatternLayout
log4j2.appender.rolling.layout.pattern = ${log4j2.pattern}
log4j2.appender.rolling.policies.type = Policies
log4j2.appender.rolling.policies.size.type = SizeBasedTriggeringPolicy
log4j2.appender.rolling.policies.size.size = 16MB

# Audit file appender
log4j2.appender.audit.type = RollingRandomAccessFile
log4j2.appender.audit.name = AuditRollingFile
log4j2.appender.audit.fileName = ${karaf.data}/log/security.log
log4j2.appender.audit.filePattern = ${karaf.data}/log/security-%i.log
log4j2.appender.audit.append = true
log4j2.appender.audit.layout.type = PatternLayout
log4j2.appender.audit.layout.pattern = %m%n
log4j2.appender.audit.policies.type = Policies
log4j2.appender.audit.policies.size.type = SizeBasedTriggeringPolicy
log4j2.appender.audit.policies.size.size = 8MB

log4j2.appender.securityAudit.type = RollingRandomAccessFile
log4j2.appender.securityAudit.name = AuditRollingFile
log4j2.appender.securityAudit.fileName = ${karaf.data}/log/audit.log
log4j2.appender.securityAudit.filePattern = ${karaf.data}/log/audit-%i.log
log4j2.appender.securityAudit.append = true
log4j2.appender.securityAudit.layout.type = PatternLayout
log4j2.appender.securityAudit.layout.pattern = ${log4j2.pattern}
log4j2.appender.securityAudit.policies.type = Policies
log4j2.appender.securityAudit.policies.size.type = SizeBasedTriggeringPolicy
log4j2.appender.securityAudit.policies.size.size = 8MB

log4j2.appender.karafAudit.type = RollingRandomAccessFile
log4j2.appender.karafAudit.name = KarafRollingFile
log4j2.appender.karafAudit.fileName = ${karaf.data}/log/karaf.log
log4j2.appender.karafAudit.filePattern = ${karaf.data}/log/karaf-%i.log
log4j2.appender.karafAudit.append = true
log4j2.appender.karafAudit.layout.type = PatternLayout
log4j2.appender.karafAudit.layout.pattern = ${log4j2.pattern}
log4j2.appender.karafAudit.policies.type = Policies
log4j2.appender.karafAudit.policies.size.type = SizeBasedTriggeringPolicy
log4j2.appender.karafAudit.policies.size.size = 8MB

# OSGi appender
log4j2.appender.osgi.type = PaxOsgi
log4j2.appender.osgi.name = PaxOsgi
log4j2.appender.osgi.filter = *

# help with identification of maven-related problems with pax-url-aether
#log4j2.logger.aether.name = shaded.org.eclipse.aether
#log4j2.logger.aether.level = TRACE
#log4j2.logger.http-headers.name = shaded.org.apache.http.headers
#log4j2.logger.http-headers.level = DEBUG
#log4j2.logger.maven.name = org.ops4j.pax.url.mvn
#log4j2.logger.maven.level = TRACE

# Kafka appender
log4j2.appender.kafka.type = Kafka
log4j2.appender.kafka.name = Kafka
log4j2.appender.kafka.property.type = Property
log4j2.appender.kafka.property.name = bootstrap.servers
log4j2.appender.kafka.property.value = {{- join "," .Values.log_agent.kafka_brokers }}
log4j2.appender.kafka.topic = onos.log
# Async send, no need to wait for Kafka ack for each record
log4j2.appender.kafka.syncSend = false
log4j2.appender.kafka.layout.type = PatternLayout
log4j2.appender.kafka.layout.pattern = ${log4j2.kafka.patter}

# Avoid recursive logging for Kafka
log4j2.logger.apacheKafka.name = org.apache.kafka
log4j2.logger.apacheKafka.level = INFO

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
