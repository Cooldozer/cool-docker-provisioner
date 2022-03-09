Sufix=$1
PlanSize=$2
PlanWorkerNo=$3
DockerInstanceNo=$4
location=$5

plan_size=${PlanSize}

prefix=an${RANDOM:0:4}
rg_name=demo_${Sufix}
reg_name=${prefix}0reg${Sufix}
plan_name=${prefix}0demo_plan_${Sufix}
service_name=${prefix}0demo${Sufix}
image_name=target
fake_image_name=fake


az login --use-device-code

if [ $(az group exists --name ${rg_name}) == true ]
then
 az group delete -n ${rg_name} --yes 
fi

az group create --name ${rg_name} --location ${location}

az acr create --name ${reg_name} --resource-group ${rg_name} --sku standard --admin-enabled true

pushd $(pwd)
cd fake
az acr build --file Dockerfile --registry ${reg_name} --image ${fake_image_name} .
popd

pushd $(pwd)
cd target
az acr build --file Dockerfile --registry ${reg_name} --image ${image_name} .
popd

sed -i "s/reg_placeholder/${reg_name}/" ./docker-compose.yml
sed -i "s/scale_placeholder/${DockerInstanceNo}/" ./docker-compose.yml

az appservice plan create --name ${plan_name} --resource-group ${rg_name} --sku ${plan_size} --number-of-workers ${PlanWorkerNo} --is-linux

echo "Renew regestry password"
password=$(az acr credential renew -n ${reg_name} --password-name password2 | jq -r .passwords[0].value)
echo ${password}
az webapp create --resource-group ${rg_name} --plan ${plan_name} --name ${service_name} --multicontainer-config-type COMPOSE --multicontainer-config-file docker-compose.yml --docker-registry-server-user ${reg_name} --docker-registry-server-password ${password}
