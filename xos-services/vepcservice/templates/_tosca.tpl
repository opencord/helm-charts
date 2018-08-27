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
{{- define "vepcservice.serviceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - custom_types/image.yaml
  - custom_types/site.yaml
  - custom_types/vepcservice.yaml
  - custom_types/slice.yaml
  - custom_types/trustdomain.yaml

description: Configures the virtual EPC service

topology_template:
  node_templates:

    default_trustdomain:
      type: tosca.nodes.TrustDomain
      properties:
        name: "default"
        must-exist: true

    service#vepcservice:
      type: tosca.nodes.VEpcService
      properties:
        name: vepcservice
    mysite:
      type: tosca.nodes.Site
      properties:
        name: "mysite"
        must-exist: true

    vepcserviceinstance:
      type: tosca.nodes.VEpcServiceInstance
      properties:
        name: "EPC2 for Compute"
      requirements:
        - owner:
            node: service#vepcservice
            relationship: tosca.relationships.BelongsToOne

    kubernetesresourceinstance_ngic_configmap:
      type: tosca.nodes.KubernetesResourceInstance
      properties:
        name: "NGIC Config Map"
        resource_definition: |
          apiVersion: v1
          data:
            adc_rules.cfg: |
              #Format  -
              #[ IP | IP Prefix | domain ] DROP? Sponsor-ID Service-ID Rate-Group? [Tariff-Group Tariff-Time]?
              # Note: it is possible that ADC rules have conflicts & in that case rules are applied by line number...
              # Rules defined first have a higher priority, unless DROP is specified (i.e. multiple rules for the same IP
              # When specifying DROP with an IP address, use a prefix of 32 to prevent DNS results from overwriting rule

              13.1.1.111 Example Internet Zero-Rate
              13.1.1.112/24 Example Management Zero-Rate
              13.1.1.113 Example Provisioning Zero-Rate
              www.example.gov Example Internet Zero-Rate
              www.drop_example.com DROP Example CIPA
            cp_config.cfg: |
              SGW_S11_IP=$(hostname)
              SGW_S1U_IP=$(netstat -ie | grep -A1 s1u-net | tail -1 | awk '{print $2}' | tr -d addr:)
              MGMT_INFO="-s ${SGW_S11_IP} -m ${MME_S11_IP} -w ${SGW_S1U_IP}"
              APN_INFO="-i ${IP_POOL_IP} -p ${IP_POOL_MASK} -a ${APN}"
              TEID_INFO="-t ${S11_TEID_POOL_START} -e ${S11_TEID_POOL_STOP} -u ${S1U_TEID_POOL_START} -o ${S1U_TEID_POOL_STOP}"
              APP_ARGS="${MGMT_INFO} ${APN_INFO} ${TEID_INFO}"

              CORES="-c $(taskset -p $$ | awk '{print $NF}')"
              MEMORY="-n4 --no-huge -m 4096 --file-prefix cp"
              DEVICES="--no-pci"
              EAL_ARGS="${CORES} ${MEMORY} ${DEVICES}"
            dp_config.cfg: |
              CORES="-c $(taskset -p $$ | awk '{print $NF}')"
              MEMORY="-n4 --no-huge -m 8192 --file-prefix cp"

              SGW_S1U_IP=$(netstat -ie | grep -A1 s1u-net | tail -1 | awk '{print $2}' | tr -d addr:)
              SGW_SGI_IP=$(netstat -ie | grep -A1 sgi-net | tail -1 | awk '{print $2}' | tr -d addr:)
              S1U_MAC=$( netstat -ie | grep -B1 $SGW_S1U_IP | head -n1 | awk '{print $5}' )
              SGI_MAC=$( netstat -ie | grep -B1 $SGW_SGI_IP | head -n1 | awk '{print $5}' )
              DEVICES="--no-pci --vdev eth_af_packet0,iface=s1u-net --vdev eth_af_packet1,iface=sgi-net"

              EAL_ARGS="${CORES} ${MEMORY} ${DEVICES}"

              S1U="--s1u_ip ${SGW_S1U_IP} --s1u_mac ${S1U_MAC}"
              SGI="--sgi_ip ${SGW_SGI_IP} --sgi_mac ${SGI_MAC} --sgi_gw_ip ${RTR_SGI_IP} --sgi_mask ${SGI_MASK}"
              WORKERS="--num_workers 1"
              MISC="--log 1"

              APP_ARGS="${S1U} ${SGI} ${WORKERS} ${MISC}"
            interface.cfg: "; Copyright (c) 2017 Intel Corporation\n;\n; Licensed under the
              Apache License, Version 2.0 (the \"License\");\n; you may not use this file except
              in compliance with the License.\n; You may obtain a copy of the License at\n;\n;
              \     http://www.apache.org/licenses/LICENSE-2.0\n;\n; Unless required by applicable
              law or agreed to in writing, software\n; distributed under the License is distributed
              on an \"AS IS\" BASIS,\n; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
              express or implied.\n; See the License for the specific language governing permissions
              and\n; limitations under the License.\n\n[0]\ndp_comm_ip =  127.0.0.1\ndp_comm_port
              = 20\ncp_comm_ip = 127.0.0.1\ncp_comm_port = 21\n"
            static_pcc.cfg: |+
              [GLOBAL]
              NUM_PACKET_FILTERS = 1

              ;default filter - must be first for now (until DP doesn't install any filters)
              [PACKET_FILTER_0]
              RATING_GROUP = 9
              ;Max Bit Rate (MBR) unit= bps
              MBR = 512000

              [PACKET_FILTER_1]
              RATING_GROUP = 5
              MBR = 1000000
              DIRECTION = bidirectional
              PRECEDENCE = 255
              IPV4_REMOTE = 13.1.0.0
              IPV4_REMOTE_MASK = 255.255.0.0
              PROTOCOL = 17
              REMOTE_LOW_LIMIT_PORT = 5060
              REMOTE_HIGH_LIMIT_PORT = 5060

              [PACKET_FILTER_2]
              RATING_GROUP = 1
              MBR = 2000000
              DIRECTION = bidirectional
              PRECEDENCE = 255
              IPV4_REMOTE = 13.1.0.0
              IPV4_REMOTE_MASK = 255.255.0.0
              PROTOCOL = 17
              LOCAL_LOW_LIMIT_PORT = 17000
              LOCAL_HIGH_LIMIT_PORT = 17010

              [PACKET_FILTER_3]
              RATING_GROUP = 7
              MBR = 4000000
              DIRECTION = bidirectional
              PRECEDENCE = 255
              IPV4_REMOTE = 13.1.0.0
              IPV4_REMOTE_MASK = 255.255.0.0
              PROTOCOL = 17
              LOCAL_LOW_LIMIT_PORT = 8000
              LOCAL_HIGH_LIMIT_PORT = 8080

          kind: ConfigMap
          metadata:
            name: ngic-config
            namespace: epc2

      requirements:
        - owner:
            node: service#kubernetes
            relationship: tosca.relationships.BelongsToOne

    kubernetesresourceinstance_mme_service:
      type: tosca.nodes.KubernetesResourceInstance
      properties:
        name: "MME Service"
        resource_definition: |
          apiVersion: v1
          kind: Service
          metadata:
            name: mme
            namespace: epc2
          spec:
            selector:
              app: mme
            clusterIP: None
            ports:
            - name: s11
              port: 2123
              protocol: UDP
            - name: s1ap
              port: 36412
              protocol: TCP
            - name: s6a
              port: 3868
              protocol: TCP

      requirements:
        - owner:
            node: service#kubernetes
            relationship: tosca.relationships.BelongsToOne

    kubernetesresourceinstance_mme_statefulset:
      type: tosca.nodes.KubernetesResourceInstance
      properties:
        name: "MME StatefulSet"
        resource_definition: |
          apiVersion: apps/v1
          kind: StatefulSet
          metadata:
            name: mme
            namespace: epc2
            labels:
              app: mme
          spec:
            replicas: 1
            selector:
              matchLabels:
                app: mme
            serviceName: "mme"
            template:
              metadata:
                labels:
                  app: mme
              spec:
                terminationGracePeriodSeconds: 1
                initContainers:
                - name: init-mme
                  image: "ngick8stesting/c3po-mmeinit"
                  command: [ "sh", "-c"]
                  securityContext:
                    capabilities:
                      add:
                        - NET_ADMIN
                  args:
                  - iptables -A OUTPUT -p sctp --sport 36412 --chunk-types any ABORT -j DROP;
                    until nslookup hss-0.hss.epc2.svc.cluster.local;
                    do echo waiting for hss; sleep 2; done;
                containers:
                - name: mme
                  image: "ngick8stesting/c3po-mme:5e2eaf6"
                  imagePullPolicy: Always
                  env:
                    - name: SGW_S11_IP
                      value: ngic-0.ngic.epc2.svc.cluster.local
                    - name: MME_ETH0_IP
                      valueFrom:
                        fieldRef:
                          fieldPath: status.podIP
                    - name: ENB_S1AP_IP
                      value: 10.1.11.3
                    - name: CONNECT_PEER
                      value: hss-0.hss.epc2.svc.cluster.local
                    - name: VAR_HSS_REALM
                      value: hss.epc2.svc.cluster.local
                    - name: HSS_S6A_IP
                      value: hss-0.hss.epc2.svc.cluster.local
                    - name: HSS_PORT
                      value: "3868"

                  stdin: true
                  tty: true
                  #command: [ "sleep", "3600"]
                  #volumeMounts:
                  #- name: config-volume
                  #  mountPath: /opt/ngic/config
                  #- name: scripts-volume
                  #  mountPath: /opt/ngic/scripts
                  #- name: hugepage
                  #  mountPath: /dev/hugepages
                  resources:
                    limits:
                      cpu: 3
                      memory: 1Gi
                #volumes:
                #  - name: config-volume
                #    configMap:
                #      name: ngic-config
                #  - name: scripts-volume
                #    secret:
                #      secretName: ngic-scripts
                #      defaultMode: 511
                #  - name: hugepage
                #    emptyDir:
                #      medium: HugePages

      requirements:
        - owner:
            node: service#kubernetes
            relationship: tosca.relationships.BelongsToOne

    kubernetesresourceinstance_hss_service:
      type: tosca.nodes.KubernetesResourceInstance
      properties:
        name: "HSS Service"
        resource_definition: |
          apiVersion: v1
          kind: Service
          metadata:
            name: hss
            namespace: epc2
          spec:
            selector:
              app: hss
            clusterIP: None
            ports:
            - name: s6a
              port: 3868
              protocol: TCP

      requirements:
        - owner:
            node: service#kubernetes
            relationship: tosca.relationships.BelongsToOne

    kubernetesresourceinstance_hss_statefulset:
      type: tosca.nodes.KubernetesResourceInstance
      properties:
        name: "HSS StatefulSet"
        resource_definition: |
          apiVersion: apps/v1
          kind: StatefulSet
          metadata:
            name: hss
            namespace: epc2
            labels:
              app: hss
          spec:
            replicas: 1
            selector:
              matchLabels:
                app: hss
            serviceName: "hss"
            template:
              metadata:
                labels:
                  app: hss
              spec:
                terminationGracePeriodSeconds: 1
                initContainers:
                - name: init-db
                  image: "ngick8stesting/c3po-cassandra:5e2eaf6"
                  command: [ "bash", "-xc"]
                  args:
                  - until nslookup cassandra; do echo waiting for cassandra; sleep 2; done;
                    cqlsh --file /scripts/oai_db.cql cassandra;
                    /scripts/data_provisioning_users.sh 208014567891200 1122334455 apn1 465B5CE8B199B49FAA5F0A2EE238A6BC 100 cassandra mme-0.mme.epc2.svc.cluster.local mme.epc2.svc.cluster.local;
                    /scripts/data_provisioning_mme.sh 1 19136246000 mme-0.mme.epc2.svc.cluster.local mme.epc2.svc.cluster.local 1 cassandra;
                    /scripts/data_provisioning_mme.sh 1 19136246000 smsrouter.test3gpp.net test3gpp.net 0  cassandra;
                containers:
                - name: hss
                  image: "ngick8stesting/c3po-hss:5e2eaf6"
                  imagePullPolicy: Always
                  env:
                    - name: CASSANDRA_ADDR
                      value: cassandra
                    - name: MME_ADDR
                      value: mme-0.mme.epc2.svc.cluster.local
                  #command: [ "sleep", "3600"]
                  resources:
                    limits:
                      cpu: 3
                      memory: 1Gi

      requirements:
        - owner:
            node: service#kubernetes
            relationship: tosca.relationships.BelongsToOne

    kubernetesresourceinstance_hssdb_service:
      type: tosca.nodes.KubernetesResourceInstance
      properties:
        name: "HSS Cassandra Service"
        resource_definition: |
          apiVersion: v1
          kind: Service
          metadata:
            labels:
              app: cassandra
            name: cassandra
            namespace: epc2
          spec:
            clusterIP: None
            ports:
              - port: 9042
            selector:
              app: cassandra

      requirements:
        - owner:
            node: service#kubernetes
            relationship: tosca.relationships.BelongsToOne

    kubernetesresourceinstance_hssdb_statefulset:
      type: tosca.nodes.KubernetesResourceInstance
      properties:
        name: "HSS Cassandra StatefulSet"
        resource_definition: |
          apiVersion: "apps/v1"
          kind: StatefulSet
          metadata:
            name: cassandra
            namespace: epc2
            labels:
              app: cassandra
          spec:
            serviceName: cassandra
            replicas: 1 # 3
            selector:
              matchLabels:
                app: cassandra
            template:
              metadata:
                labels:
                  app: cassandra
              spec:
                terminationGracePeriodSeconds: 1
                containers:
                - name: cassandra
                  image: ngick8stesting/c3po-cassandra:5e2eaf6
                  imagePullPolicy: Always
                  ports:
                  - containerPort: 7000
                    name: intra-node
                  - containerPort: 7001
                    name: tls-intra-node
                  - containerPort: 7199
                    name: jmx
                  - containerPort: 9042
                    name: cql
                  resources:
                    limits:
                      cpu: "3"
                      memory: 4Gi
                  # Probably Cassandra:3.x?
                  #securityContext:
                  #  capabilities:
                  #    add:
                  #      - IPC_LOCK
                  # Later
                  #lifecycle:
                  #  preStop:
                  #    exec:
                  #      command:
                  #      - /bin/sh
                  #      - -c
                  #      - nodetool drain
                  env:
                  # Performance optimizations
                    - name: MAX_HEAP_SIZE
                      value: 512M
                    - name: HEAP_NEWSIZE
                      value: 100M
                    - name: CASSANDRA_SEEDS
                      value: "cassandra-0.cassandra.epc2.svc.cluster.local"
                    - name: CASSANDRA_CLUSTER_NAME
                      value: "HSS Cluster"
                    - name: CASSANDRA_RPC_ADDRESS
                      valueFrom:
                        fieldRef:
                          fieldPath: status.podIP
                    - name: CASSANDRA_ENDPOINT_SNITCH
                      value: "GossipingPropertyFileSnitch"
                  readinessProbe:
                    exec:
                      command: ["/bin/bash", "-c", "nodetool status -r | awk -v h=$(hostname) '$2==h {exit ($1==\"UN\" ? 0 : -1)}'"]
                    initialDelaySeconds: 15
                    timeoutSeconds: 5
          #        volumeMounts:
          #        - name: cassandra-data
          #          mountPath: /var/lib/cassandra
          #  volumeClaimTemplates:
          #  - metadata:
          #      name: cassandra-data
          #    spec:
          #      accessModes: [ "ReadWriteOnce" ]
          #      resources:
          #        requests:
          #          storage: 1Gi

      requirements:
        - owner:
            node: service#kubernetes
            relationship: tosca.relationships.BelongsToOne

    kubernetesresourceinstance_spgwcu_service:
      type: tosca.nodes.KubernetesResourceInstance
      properties:
        name: "SPGW Control and User Service"
        resource_definition: |
          apiVersion: v1
          kind: Service
          metadata:
            name: ngic
            namespace: epc2
          spec:
            selector:
              app: ngic
            clusterIP: None
            ports:
            - name: s11
              port: 2123
              protocol: UDP

      requirements:
        - owner:
            node: service#kubernetes
            relationship: tosca.relationships.BelongsToOne

    kubernetesresourceinstance_spgwcu_statefulset:
      type: tosca.nodes.KubernetesResourceInstance
      properties:
        name: "SPGW Control and User StatefulSet"
        resource_definition: |
          apiVersion: apps/v1
          kind: StatefulSet
          metadata:
            name: ngic
            namespace: epc2
            labels:
              app: ngic
          spec:
            replicas: 1
            selector:
              matchLabels:
                app: ngic
            serviceName: "ngic"
            template:
              metadata:
                labels:
                  app: ngic
                annotations:
                  kubernetes.v1.cni.cncf.io/networks: '[
                          { "name": "s1u-net", "interfaceRequest": "s1u-net" },
                          { "name": "sgi-net", "interfaceRequest": "sgi-net" }
                  ]'        
              spec:
                initContainers:
                - name: init-iptables
                  image: "ngick8stesting/c3po-mmeinit"
                  command: [ "sh", "-c"]
                  securityContext:
                    capabilities:
                      add:
                        - NET_ADMIN
                  args:
                  - iptables -I OUTPUT -p icmp --icmp-type destination-unreachable -j DROP;
                terminationGracePeriodSeconds: 1
                containers:
                - name: ngic-cp
                  image: "ngick8stesting/ngic-cp:d9b315c"
                  stdin: true
                  command: [ "bash",  "-cx", ". /opt/ngic/config/cp_config.cfg; ./ngic_controlplane  $EAL_ARGS -- $APP_ARGS"]
                  #command: ["sleep", "3600"]
                  tty: true
                  env:
                    - name: MME_S11_IP
                      value: mme-0.mme.epc2.svc.cluster.local
                    #- name: SGW_S1U_IP  # for now,this will be in our own pod
                    #  value: "5.5.5.5"
                    - name: APN
                      value: apn1
                    - name: IP_POOL_IP
                      value: "16.0.0.0"
                    - name: IP_POOL_MASK
                      value: "255.240.0.0"
                    - name: S11_TEID_POOL_START
                      value: "00100000"
                    - name: S11_TEID_POOL_STOP
                      value: "001fffff"
                    - name: S1U_TEID_POOL_START
                      value: "00100000"
                    - name: S1U_TEID_POOL_STOP
                      value: "001fffff"
                  volumeMounts:
                  - name: config-volume
                    mountPath: /opt/ngic/config
                  #- name: hugepage
                  #  mountPath: /dev/hugepages
                  resources:
                    limits:
                      #hugepages-2Mi: 4Gi
                      cpu: 3
                      memory: 4Gi
                - name: ngic-dp
                  image: "ngiccorddemo/ngic-dp:k8s-bm"
                  stdin: true
                  tty: true
                  env:
                  - name: RTR_SGI_IP 
                    value: "13.1.1.110"
                  - name: SGI_MASK
                    value: "255.255.255.0"
                  command: [ "bash",  "-cx", ". /opt/ngic/config/dp_config.cfg ; ./ngic_dataplane  $EAL_ARGS -- $APP_ARGS"]
                  #command: ["sleep", "3600"]
                  volumeMounts:
                  - name: config-volume
                    mountPath: /opt/ngic/config
                  #- name: hugepage
                  #  mountPath: /dev/hugepages
                  resources:
                    limits:
                      #hugepages-1Gi: 8Gi
                      cpu: 8
                      memory: 8Gi #200Mi
                      intel.com/sriov: '2'            
                  securityContext:
                    privileged: true
                    capabilities:
                      add:
                        - NET_ADMIN
                        - IPC_LOCK            
                volumes:
                  - name: config-volume
                    configMap:
                      name: ngic-config
                  #- name: hugepage
                  #  emptyDir:
                  #    medium: HugePages

      requirements:
        - owner:
            node: service#kubernetes
            relationship: tosca.relationships.BelongsToOne

    vepcresourceinstancelink_ngic_configmap:
      type: tosca.nodes.VEpcResourceInstanceLink
      properties:
         name: "NGIC ConfigMap Resource Link"

      requirements:
        - resource_instance:
            node: kubernetesresourceinstance_ngic_configmap
            relationship: tosca.relationships.BelongsToOne
        - vepc_service_instance:
            node: vepcserviceinstance
            relationship: tosca.relationships.BelongsToOne

    vepcresourceinstancelink_mme_service:
      type: tosca.nodes.VEpcResourceInstanceLink
      properties:
         name: "MME Service Resource Link"

      requirements:
        - resource_instance:
            node: kubernetesresourceinstance_mme_service
            relationship: tosca.relationships.BelongsToOne
        - vepc_service_instance:
            node: vepcserviceinstance
            relationship: tosca.relationships.BelongsToOne

    vepcresourceinstancelink_mme_statefulset:
      type: tosca.nodes.VEpcResourceInstanceLink
        properties:
          name: "MME StatefulSet Resource Link"

        requirements:
          - resource_instance:
              node: kubernetesresourceinstance_mme_statefulset
              relationship: tosca.relationships.BelongsToOne
          - vepc_service_instance:
              node: vepcserviceinstance
              relationship: tosca.relationships.BelongsToOne

    vepcresourceinstancelink_hss_service:
      type: tosca.nodes.VEpcResourceInstanceLink
      properties:
         name: "HSS Service Resource Link"

      requirements:
        - resource_instance:
            node: kubernetesresourceinstance_hss_service
            relationship: tosca.relationships.BelongsToOne
        - vepc_service_instance:
            node: vepcserviceinstance
            relationship: tosca.relationships.BelongsToOne

    vepcresourceinstancelink_hss_statefulset:
      type: tosca.nodes.VEpcResourceInstanceLink
        properties:
          name: "HSS StatefulSet Resource Link"

        requirements:
          - resource_instance:
              node: kubernetesresourceinstance_hss_statefulset
              relationship: tosca.relationships.BelongsToOne
          - vepc_service_instance:
              node: vepcserviceinstance
              relationship: tosca.relationships.BelongsToOne

    vepcresourceinstancelink_hssdb_service:
      type: tosca.nodes.VEpcResourceInstanceLink
      properties:
         name: "HSS Cassandra Service Resource Link"

      requirements:
        - resource_instance:
            node: kubernetesresourceinstance_hssdb_service
            relationship: tosca.relationships.BelongsToOne
        - vepc_service_instance:
            node: vepcserviceinstance
            relationship: tosca.relationships.BelongsToOne

    vepcresourceinstancelink_hssdb_statefulset:
      type: tosca.nodes.VEpcResourceInstanceLink
        properties:
          name: "HSS Cassandra StatefulSet Resource Link"

        requirements:
          - resource_instance:
              node: kubernetesresourceinstance_hssdb_statefulset
              relationship: tosca.relationships.BelongsToOne
          - vepc_service_instance:
              node: vepcserviceinstance
              relationship: tosca.relationships.BelongsToOne

    vepcresourceinstancelink_spgwcu_service:
      type: tosca.nodes.VEpcResourceInstanceLink
      properties:
         name: "SPGW Contol and User Service Resource Link"

      requirements:
        - resource_instance:
            node: kubernetesresourceinstance_spgwcu_service
            relationship: tosca.relationships.BelongsToOne
        - vepc_service_instance:
            node: vepcserviceinstance
            relationship: tosca.relationships.BelongsToOne

    vepcresourceinstancelink_spgwcu_statefulset:
      type: tosca.nodes.VEpcResourceInstanceLink
        properties:
          name: "HS SPGW Control and User StatefulSet Resource Link"

        requirements:
          - resource_instance:
              node: kubernetesresourceinstance_spgwcu_statefulset
              relationship: tosca.relationships.BelongsToOne
          - vepc_service_instance:
              node: vepcserviceinstance
              relationship: tosca.relationships.BelongsToOne
{{- end -}}
