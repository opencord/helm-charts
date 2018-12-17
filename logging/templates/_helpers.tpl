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

{{- define "logging.logstash-input" }}
    input {
          kafka {
            auto_offset_reset => "earliest" # get all previous items from new topics
            bootstrap_servers => {{ .Values.platformKafka }}
            client_id => "logstash_ck"
            codec => json { charset => "UTF-8" }
            consumer_threads => 1
            decorate_events => true
            group_id => "logstash_ck"
            metadata_max_age_ms => 60000 # recheck for new topics every minute
            # other topics that are not indexed: xos.gui_events, voltha.kpis, voltha.heartbeat
            topics_pattern => '.*\.events|dhcp.*|onos.*|.*\.log.*'
            type => {{ .Values.platformKafka }}
          }
        }
{{- end }}

