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
image_name=${prefix}0demo${Sufix}

az login --use-device-code

if [ $(az group exists --name ${rg_name}) == true ]
then
 az group delete -n ${rg_name} --yes 
fi

az group create --name ${rg_name} --location ${location}

az acr create --name ${reg_name} --resource-group ${rg_name} --sku standard --admin-enabled true
az acr build --file Dockerfile --registry ${reg_name} --image ${image_name} .

az appservice plan create --name ${plan_name} --resource-group ${rg_name} --sku ${plan_size} --number-of-workers ${PlanWorkerNo} --is-linux

for (( i=1; i <= ${appservice_no}; i++ ))
do
     az webapp create --resource-group ${rg_name} --plan ${plan_name} --name ${service_name}-${i} --deployment-container-image-name ${reg_name}.azurecr.io/${image_name}:latest
done