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
{{- define "exampleservice.serviceTosca" -}}
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
   - custom_types/slice.yaml
   - custom_types/site.yaml
   - custom_types/image.yaml
   - custom_types/flavor.yaml
   - custom_types/network.yaml
   - custom_types/networktemplate.yaml
   - custom_types/networkslice.yaml
   - custom_types/openstackservice.yaml
   - custom_types/trustdomain.yaml
   - custom_types/exampleservice.yaml
   - custom_types/exampleserviceinstance.yaml

description: configure exampleservice

topology_template:
  node_templates:
    service#openstack:
      type: tosca.nodes.OpenStackService
      properties:
          name: "OpenStack"
          must-exist: true

    untrusted_trustdomain:
      type: tosca.nodes.TrustDomain
      properties:
        name: "untrusted-openstack"
      requirements:
        - owner:
            node: service#openstack
            relationship: tosca.relationships.BelongsToOne

# site, image, fully created in deployment.yaml
    mysite:
      type: tosca.nodes.Site
      properties:
        must-exist: true
        name: {{ .cordSiteName }}

    m1.small:
      type: tosca.nodes.Flavor
      properties:
        name: m1.small
        must-exist: true

    trusty-server-multi-nic:
      type: tosca.nodes.Image
      properties:
        name: "trusty-server-multi-nic"
        container_format: "BARE"
        disk_format: "QCOW2"
        path: "https://github.com/opencord/platform-install/releases/download/vms/trusty-server-cloudimg-amd64-disk1.img.20170201"

# private network template, fully created somewhere else
    private:
      type: tosca.nodes.NetworkTemplate
      properties:
        must-exist: true
        name: Private

# management networks, fully created in management-net.yaml
    management_network:
      type: tosca.nodes.Network
      properties:
        must-exist: true
        name: management

# public network, fully created somewhere else
    public_network:
      type: tosca.nodes.Network
      properties:
        must-exist: true
        name: public

    exampleservice_network:
      type: tosca.nodes.Network
      properties:
          name: exampleservice_network
          labels: exampleservice_private_network
      requirements:
          - template:
              node: private
              relationship: tosca.relationships.BelongsToOne
          - owner:
              node: exampleservice_slice
              relationship: tosca.relationships.BelongsToOne

# ExampleService Slices
    exampleservice_slice:
      description: Example Service Slice
      type: tosca.nodes.Slice
      properties:
          name: exampleservice
          default_isolation: vm
          network: noauto
      requirements:
          - site:
              node: mysite
              relationship: tosca.relationships.BelongsToOne
          - service:
              node: exampleservice
              relationship: tosca.relationships.BelongsToOne
          - default_image:
              node: trusty-server-multi-nic
              relationship: tosca.relationships.BelongsToOne
          - default_flavor:
              node: m1.small
              relationship: tosca.relationships.BelongsToOne
          - trust_domain:
              node: untrusted_trustdomain
              relationship: tosca.relationships.BelongsToOne

# ExampleService NetworkSlices
    exampleservice_slice_management_network:
      type: tosca.nodes.NetworkSlice
      requirements:
        - network:
            node: management_network
            relationship: tosca.relationships.BelongsToOne
        - slice:
            node: exampleservice_slice
            relationship: tosca.relationships.BelongsToOne

    exampleservice_slice_public_network:
      type: tosca.nodes.NetworkSlice
      requirements:
        - network:
            node: public_network
            relationship: tosca.relationships.BelongsToOne
        - slice:
            node: exampleservice_slice
            relationship: tosca.relationships.BelongsToOne

    exampleservice_slice_exampleservice_network:
      type: tosca.nodes.NetworkSlice
      requirements:
        - network:
            node: exampleservice_network
            relationship: tosca.relationships.BelongsToOne
        - slice:
            node: exampleservice_slice
            relationship: tosca.relationships.BelongsToOne

    exampleservice:
      type: tosca.nodes.ExampleService
      properties:
        name: exampleservice
        public_key: {{ .publicKey | quote }}
        private_key_fn: /opt/xos/services/exampleservice/keys/id_rsa
        service_message: hello

    exampletenant1:
      type: tosca.nodes.ExampleServiceInstance
      properties:
        name: exampletenant1
        tenant_message: world
      requirements:
        - owner:
            node: exampleservice
            relationship: tosca.relationships.BelongsToOne
{{- end -}}
