CERTS_DIR ?= certs
CA_KEYS := $(CERTS_DIR)/ca.pem $(CERTS_DIR)/ca-key.pem $(CERTS_DIR)/ca.csr
SERVER_KEYS := $(CERTS_DIR)/server.crt $(CERTS_DIR)/server.key $(CERTS_DIR)/server.csr

.PHONY: all
all: etcd
				dune exec -- ./bin.exe

$(CA_KEYS):
				cfssl gencert -initca $(CERTS_DIR)/ca-csr.json | cfssljson -bare $(CERTS_DIR)/ca -

$(SERVER_KEYS): $(CA_KEYS)
				cfssl gencert -ca=$(CERTS_DIR)/ca.pem -ca-key=$(CERTS_DIR)/ca-key.pem -config=$(CERTS_DIR)/ca-config.json -profile=server $(CERTS_DIR)/server.json | cfssljson -bare $(CERTS_DIR)/server -
				mv $(CERTS_DIR)/server.pem $(CERTS_DIR)/server.crt
				mv $(CERTS_DIR)/server-key.pem $(CERTS_DIR)/server.key

.PHONY: etcd
etcd: $(SERVER_KEYS)
				docker kill etcd || true
				docker run --rm -d --name etcd -v $$PWD/certs:/etc/etcd/pki:ro -p 2379:2379 quay.io/coreos/etcd:v3.4.13 etcd --cert-file '/etc/etcd/pki/server.crt' --key-file '/etc/etcd/pki/server.key' --listen-client-urls 'https://0.0.0.0:2379' --advertise-client-urls 'https://0.0.0.0:2379'