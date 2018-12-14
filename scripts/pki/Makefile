# Copyright 2017-present Open Networking Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# XOS pki makefile
# Configuration is also given in xos-pki.cnf

SHELL = bash -eu -o pipefail

# parameters
KEY_SIZE         ?= 2048
EXPIRATION_DAYS  ?= 366
OPENSSL_CNF      ?= xos-pki.cnf

# utility/validation targets

help:
	@echo "Usually you want to run 'make all_certs'"

validate:
	 openssl verify -verbose -purpose sslserver -CAfile xos-CA.pem xos-core.crt

printca: xos-CA.pem
	openssl x509 -in $< -text -noout

printkey: xos-core.key
	openssl rsa -in $< -check

printcsr: xos-core.csr
	openssl req -in $< -text -noout -verify

printpem: xos-core.pem
	openssl x509 -in $< -text -noout

all_certs: xos-core.pem

clean:
	rm -rf root_ca *.pem *.key *.csr

# CA creation
root_ca:
	mkdir -p root_ca/private root_ca/newcerts
	chmod 700 root_ca/private
	echo 1000 > root_ca/serial
	touch root_ca/index.txt

root_ca/private/ca_root_phrase: root_ca
	@echo "TestingXOSRootCAPassPhrase" > root_ca/private/ca_root_phrase

root_ca/private/ca_key.pem: root_ca root_ca/private/ca_root_phrase
	@echo "## Creating CA private key, $@"
	openssl genrsa -aes256 \
	  -passout file:root_ca/private/ca_root_phrase \
	  -out root_ca/private/ca_key.pem $(KEY_SIZE)

xos-CA.pem: xos-pki.cnf root_ca/private/ca_key.pem
	@echo "## Creating self-signed CA public key: $@"
	openssl req -config $(OPENSSL_CNF) \
	  -new -x509 -days $(EXPIRATION_DAYS) -sha256 \
	  -extensions v3_ca \
	  -key root_ca/private/ca_key.pem \
	  -passin file:root_ca/private/ca_root_phrase \
	  -subj "/C=US/ST=California/L=Menlo Park/O=ONF/OU=Testing Only/CN=CORD Test Root CA" \
	  -out $@

# cert creation
.PRECIOUS: %.key %.csr # don't delete intermediate files

%.key:
	@echo "## Creating server private key: $@"
	openssl genrsa -out $@ $(KEY_SIZE)

%.csr: %.key $(OPENSSL_CNF)
	@echo "## Creating signing request $@ from $<"
	openssl req -config $(OPENSSL_CNF) \
	  -new -sha256 -key $< \
	  -subj "/C=US/ST=California/L=Menlo Park/O=ONF/OU=Testing Only/CN=$*" \
	  -out $@

%.pem: %.csr xos-CA.pem $(OPENSSL_CNF)
	@echo "## Signing voltha.csr to create signed public key: voltha.crt"
	openssl ca -config $(OPENSSL_CNF) \
	  -batch -days $(EXPIRATION_DAYS) -md sha256 \
	  -passin file:root_ca/private/ca_root_phrase \
	  -extensions $* \
	  -in $< \
	  -out $@
