Sufix=$1
PlanSize=$2
PlanWorkerNo=$3
DockerInstanceNo=$4
location=$5

appservice_no=${DockerInstanceNo};
plan_size=${PlanSize}

prefix=an${RANDOM:0:4}
rg_name=demo_${Sufix}
reg_name=${prefix}0reg${Sufix}
plan_name=${prefix}0demo_plan_${Sufix}
service_name=${prefix}0demo${Sufix}
image_name=target
fake_image_name=fake

ls
az login --use-device-code

if [ $(az group exists --name ${rg_name}) == true ]
then
 az group delete -n ${rg_name} --yes 
fi

az group create --name ${rg_name} --location ${location}

az acr create --name ${reg_name} --resource-group ${rg_name} --sku standard --admin-enabled true
pushd $(pwd)
cd fake
ls
az acr build --file Dockerfile --registry ${reg_name} --image ${fake_image_name} .
popd
pushd $(pwd)
cd target
ls
az acr build --file Dockerfile --registry ${reg_name} --image ${image_name} .
popd
ls
sed -i 's/placeholder/${reg_name}/' ./docker-compose.yml
ls
az appservice plan create --name ${plan_name} --resource-group ${rg_name} --sku ${plan_size} --number-of-workers ${PlanWorkerNo} --is-linux
ls
az webapp create --resource-group ${rg_name} --plan ${plan_name} --name ${service_name} --multicontainer-config-type COMPOSE --multicontainer-config-file docker-compose.yml
