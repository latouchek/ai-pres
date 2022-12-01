####
export INFRAENV_ID=$(curl -X GET "$AI_URL/api/assisted-install/v2/infra-envs" -H "accept: application/json" | jq -r '.[].id' | awk 'NR<2')
echo $INFRAENV_
#####
export CLUSTER_ID=$(curl -s -X GET "$AI_URL/api/assisted-install/v2/clusters?with_hosts=true" -H "accept: application/json" -H "get_unregistered_clusters: false"| jq -r '.[].id')
echo $CLUSTER_ID


####list hosts#####

curl -s -X GET "$AI_URL/api/assisted-install/v2/clusters?with_hosts=true"\
     -H "accept: application/json" -H "get_unregistered_clusters: false"| jq -r '.[].hosts[].id'


#####Delete host#######

for i in `curl -s -X GET "$AI_URL/api/assisted-install/v2/clusters?with_hosts=true"\
     -H "accept: application/json" -H "get_unregistered_clusters: false"| jq -r '.[].hosts[].id'| awk 'NR>0' |awk '{print $1;}'`
do curl -X DELETE "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts/$i" -H "accept: application/json"
done




####Delete infra####
curl -X DELETE "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID" -H "accept: application/json"


#####Delete cluster
curl -X DELETE "$AI_URL/api/assisted-install/v2/clusters/$CLUSTER_ID" -H "accept: application/json"