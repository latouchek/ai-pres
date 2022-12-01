curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts"
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'                                                                                                                               
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq .                                                                                                                          
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq -r '.[].hosts[].id'                                                                                                        
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq .                                                                                                                          
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq .|more                                                                                                                     
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq .[].hosts[].id                                                                                                             
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq .[].                                                                                                                       
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq .[].id                                                                                                                     
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq -r .[].id                                                                                                                  
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq -r .[].role                                                                                                                
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq -r .[].progress                                                                                                            
curl -X 'GET' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts" -H 'accept: application/json'|jq -r .[].id                                                                                                                  
curl -s -X GET "$AI_URL/api/assisted-install/v2/clusters?with_hosts=true"     -H "accept: application/json" -H "get_unregistered_clusters: false"| jq -r '.[].hosts[].id'





######assign roles#######

for i in `curl -s -X GET "$AI_URL/api/assisted-install/v2/clusters?with_hosts=true"\
     -H "accept: application/json" -H "get_unregistered_clusters: false"| jq -r '.[].hosts[].id'| awk 'NR>0' |awk '{print $1;}'`
do curl -X PATCH "$AI_URL/api/assisted-install/v2/clusters/$CLUSTER_ID" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"hosts_roles\": [ { \"id\": \"$i\", \"role\": \"master\" } ]}"
done

curl -X 'PATCH' \
  "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts/4fdcab80-cf25-4652-b37e-f659ce12a9f9" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "host_role": "master",
  "host_name": "master1"
}'

for i in `curl -s -X GET "$AI_URL/api/assisted-install/v2/clusters?with_hosts=true"\
     -H "accept: application/json" -H "get_unregistered_clusters: false"| jq -r '.[].hosts[].id'| awk 'NR>0' |awk '{print $1;}'`
do curl -X 'PATCH' "$AI_URL/api/assisted-install/v2/infra-envs/$INFRAENV_ID/hosts/$i" -H 'accept: application/json' -H 'Content-Type: application/json' -d '{ "host_role": "master"}'
done   
