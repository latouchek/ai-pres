export AI_URL='http://10.17.3.1:8090'
export NIC_CONFIG='bond-static'
export BASE_DNS_DOMAIN='lab.local'
export CLUSTER_NAME="ocpd"
export MACHINE_CIDR="10.17.3.0/24"
export VERSION="4.11"
jq -n  --arg PULLSECRET "$(cat pull-secret.json)" --arg SSH_KEY "$(cat ~/.ssh/id_ed25519.pub)" --arg VERSION "$VERSION" --arg DOMAIN "$BASE_DNS_DOMAIN" --arg CLUSTERN "$CLUSTER_NAME" --arg CIDR "$MACHINE_CIDR" '{
    "kind": "Cluster",
    "name": $CLUSTERN,
    "openshift_version": $VERSION,
    "base_dns_domain": $DOMAIN,
    "hyperthreading": "all",
    "api_vip": "10.17.3.2",
    "ingress_vip": "10.17.3.3",
    "schedulable_masters": false,
    "platform": {
      "type": "baremetal"
     },
    "user_managed_networking": false,
    "cluster_networks": [
      {
        "cidr": "172.20.0.0/16",
        "host_prefix": 23
      }
    ],
    "service_networks": [
      {
        "cidr": "172.31.0.0/16"
      }
    ],
    "machine_networks": [
      {
        "cidr": $CIDR
      }
    ],
    "olm_operators": [
      {
        "name": "cnv",
        "namespace": "openshift-cnv",
        "operator_type": "olm",
        "subscription_name": "hco-operatorhub",
        "timeout_seconds": 3600
      },
      {
        "name": "lso",
        "namespace": "openshift-local-storage",
        "operator_type": "olm",
        "subscription_name": "local-storage-operator",
        "timeout_seconds": 4200
      },
      {
        "name": "odf",
        "namespace": "openshift-storage",
        "operator_type": "olm",
        "subscription_name": "odf-operator",
        "timeout_seconds": 1800
      }
    ],
    "network_type": "OVNKubernetes",
    "additional_ntp_source": "ntp1.hetzner.de",
    "vip_dhcp_allocation": false,
    "high_availability_mode": "Full",
    "hosts": [], 
    "ssh_public_key": $SSH_KEY,
    "pull_secret": $PULLSECRET
}' > deployment.json

curl -s -X POST "$AI_URL/api/assisted-install/v2/clusters" \
  -d @./deployment.json \
  --header "Content-Type: application/json" \
  | jq .

export CLUSTER_ID=$(curl -s -X GET "$AI_URL/api/assisted-install/v2/clusters?with_hosts=true" -H "accept: application/json" -H "get_unregistered_clusters: false"| jq -r '.[].id')
echo $CLUSTER_ID
rm -f deployment.json


####Get install-config.yaml###
curl -X 'GET'   "$AI_URL/api/assisted-install/v2/clusters/$CLUSTER_ID/install-config"   -H 'accept: application/json'   -H 'Content-Type: application/json'|jq -r .


######prepare infra####

jq -n --arg CLUSTERID "$CLUSTER_ID" --arg PULLSECRET "$(cat pull-secret.json)" \
      --arg SSH_KEY "$(cat ~/.ssh/id_ed25519.pub)" \
      --arg VERSION "$VERSION" \
      --arg NMSTATEM_YAML0 "$(cat ./$NIC_CONFIG/nmstate-$NIC_CONFIG-master0.yaml)" --arg NMSTATEM_YAML1 "$(cat ./$NIC_CONFIG/nmstate-$NIC_CONFIG-master1.yaml)" --arg NMSTATEM_YAML2 "$(cat ./$NIC_CONFIG/nmstate-$NIC_CONFIG-master2.yaml)" \
      --arg NMSTATE_YAML0 "$(cat ./$NIC_CONFIG/nmstate-$NIC_CONFIG-worker0.yaml)" --arg NMSTATE_YAML1 "$(cat ./$NIC_CONFIG/nmstate-$NIC_CONFIG-worker1.yaml)" --arg NMSTATE_YAML2 "$(cat ./$NIC_CONFIG/nmstate-$NIC_CONFIG-worker2.yaml)" '{
  "name": "ocpd_infra-env",
  "openshift_version": $VERSION,
  "pull_secret": $PULLSECRET,
  "ssh_authorized_key": $SSH_KEY,
  "image_type": "full-iso",
  "cluster_id": $CLUSTERID,
  "static_network_config": [
    {
      "network_yaml": $NMSTATEM_YAML0,
      "mac_interface_map": [{"mac_address": "aa:bb:cc:11:42:10", "logical_nic_name": "ens3"}, {"mac_address": "aa:bb:cc:11:42:c0", "logical_nic_name": "ens4"}]
    },
    {
      "network_yaml": $NMSTATEM_YAML1,
      "mac_interface_map": [{"mac_address": "aa:bb:cc:11:42:11", "logical_nic_name": "ens3"}, {"mac_address": "aa:bb:cc:11:42:c1", "logical_nic_name": "ens4"}]
    },
    {
      "network_yaml": $NMSTATEM_YAML2,
      "mac_interface_map": [{"mac_address": "aa:bb:cc:11:42:12", "logical_nic_name": "ens3"}, {"mac_address": "aa:bb:cc:11:42:c2", "logical_nic_name": "ens4"}]
    },
    {
      "network_yaml": $NMSTATE_YAML0,
      "mac_interface_map": [{"mac_address": "aa:bb:cc:11:42:20", "logical_nic_name": "ens3"}, {"mac_address": "aa:bb:cc:11:42:50", "logical_nic_name": "ens4"},{"mac_address": "aa:bb:cc:11:42:60", "logical_nic_name": "ens5"}]
    },
    {
      "network_yaml": $NMSTATE_YAML1,
      "mac_interface_map": [{"mac_address": "aa:bb:cc:11:42:21", "logical_nic_name": "ens3"}, {"mac_address": "aa:bb:cc:11:42:51", "logical_nic_name": "ens4"},{"mac_address": "aa:bb:cc:11:42:61", "logical_nic_name": "ens5"}]
    },
    {
      "network_yaml": $NMSTATE_YAML2,
      "mac_interface_map": [{"mac_address": "aa:bb:cc:11:42:22", "logical_nic_name": "ens3"}, {"mac_address": "aa:bb:cc:11:42:52", "logical_nic_name": "ens4"},{"mac_address": "aa:bb:cc:11:42:62", "logical_nic_name": "ens5"}]
    }
  ]
}' > nmstate-$NIC_CONFIG

curl -H "Content-Type: application/json" -X POST -d @nmstate-$NIC_CONFIG ${AI_URL}/api/assisted-install/v2/infra-envs | jq .

export INFRAENV_ID=$(curl -X GET "$AI_URL/api/assisted-install/v2/infra-envs" -H "accept: application/json" | jq -r '.[].id' | awk 'NR<2')
echo $INFRAENV_ID

rm -rf nmstate-$NIC_CONFIG


ISO_URL=$(curl -X GET "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/downloads/image-url" -H "accept: application/json"|jq -r .url)
rm -rf /var/lib/libvirt/images/discovery_image_ocpd.iso
curl -X GET "$ISO_URL" -H "accept: application/octet-stream" -o /var/lib/libvirt/images/discovery_image.iso

terraform  -chdir=../terraform/ocp4-lab apply -auto-approve

Sleep 120 

#####Trigger deployment##### 

curl -X POST \
  "$AI_URL/api/assisted-install/v2/clusters/$CLUSTER_ID/actions/install" \
  -H "accept: application/json" \
  -H "Content-Type: application/json"

Sleep 1200


rm -rf ~/.kube
mkdir ~/.kube
curl -X GET $AI_URL/api/assisted-install/v2/clusters/$CLUSTER_ID/downloads/credentials?file_name=kubeconfig \
     -H 'accept: application/octet-stream' > /root/.kube/config



