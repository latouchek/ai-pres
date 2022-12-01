export AI_URL='http://10.17.3.1:8090'
export NIC_CONFIG='static-hub'
export BASE_DNS_DOMAIN='snolab.local'
export CLUSTER_NAME="ocpd"
export MACHINE_CIDR="10.17.4.0/24"
export VERSION="4.11"



jq -n  --arg PULLSECRET "$(cat pull-secret.json)" --arg SSH_KEY "$(cat ~/.ssh/id_ed25519.pub)" --arg VERSION "$VERSION" --arg DOMAIN "$BASE_DNS_DOMAIN" --arg CLUSTERN "$CLUSTER_NAME" --arg CIDR "$MACHINE_CIDR" '{
    "kind": "Cluster",
    "name": $CLUSTERN,
    "openshift_version": $VERSION,
    "base_dns_domain": $DOMAIN,
    "hyperthreading": "all",
    "platform": {
      "type": "baremetal"
     },
    "user_managed_networking": true,
    "cluster_networks": [
    {
      "cidr": "10.128.0.0/14",
      "host_prefix": 23
    },
    {
      "cidr": "fd01::/48",
      "host_prefix": 64
    }
  ],
  "service_networks": [
    {"cidr": "172.30.0.0/16"}, {"cidr": "fd02::/112"}
  ],
  "machine_networks": [
    {"cidr": $CIDR},{"cidr": "2001:db8:ca2:2::/64"}
  ],
    "network_type": "OVNKubernetes",
    "additional_ntp_source": "10.17.4.1",
    "vip_dhcp_allocation": false,
    "high_availability_mode": "None",
    "hosts": [], 
    "ssh_public_key": $SSH_KEY,
    "pull_secret": $PULLSECRET
}' > deployment-sno.json

curl -s -X POST "$AI_URL/api/assisted-install/v2/clusters" \
  -d @./deployment-sno.json \
  --header "Content-Type: application/json" \
  | jq .

export CLUSTER_ID=$(curl -s -X GET "$AI_URL/api/assisted-install/v2/clusters?with_hosts=true" -H "accept: application/json" -H "get_unregistered_clusters: false"| jq -r '.[].id')
echo $CLUSTER_ID
rm -f deployment-sno.json


####Get install-config.yaml###
curl -X 'GET'   "$AI_URL/api/assisted-install/v2/clusters/$CLUSTER_ID/install-config"   -H 'accept: application/json'   -H 'Content-Type: application/json'|jq -r .


######prepare infra####

jq -n --arg CLUSTERID "$CLUSTER_ID" --arg PULLSECRET "$(cat pull-secret.json)" \
      --arg SSH_KEY "$(cat ~/.ssh/id_ed25519.pub)" \
      --arg NMSTATEM_YAML0 "$(cat ./$NIC_CONFIG/nmstate-$NIC_CONFIG-sno0.yaml)" \
      --arg VERSION "$VERSION" '{
  "name": "ocpd_infra-env",
  "openshift_version": $VERSION,
  "pull_secret": $PULLSECRET,
  "ssh_authorized_key": $SSH_KEY,
  "image_type": "full-iso",
  "cluster_id": $CLUSTERID,
  "static_network_config": [
    {
      "network_yaml": $NMSTATEM_YAML0,
      "mac_interface_map": [{"mac_address": "ba:bb:cc:11:82:20", "logical_nic_name": "ens3"}, {"mac_address": "ba:ba:cc:11:82:20", "logical_nic_name": "ens4"}]
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

terraform  -chdir=../terraform/sno apply -auto-approve

sleep 240

#####Trigger deployment##### 

curl -X POST \
  "$AI_URL/api/assisted-install/v2/clusters/$CLUSTER_ID/actions/install" \
  -H "accept: application/json" \
  -H "Content-Type: application/json"


######Wait for deployment to  completes #### 
##read -p "Press any key when deployment is done " -n1 -s

sleep 1800

rm -rf ~/.kube
mkdir ~/.kube
curl -X GET $AI_URL/api/assisted-install/v2/clusters/$CLUSTER_ID/downloads/credentials?file_name=kubeconfig \
     -H 'accept: application/octet-stream' > /root/.kube/config

