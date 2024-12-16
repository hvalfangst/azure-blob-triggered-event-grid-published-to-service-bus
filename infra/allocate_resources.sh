az bicep upgrade;

az bicep build --file infra/main.bicep;

az deployment group create --resource-group hvalfangstresourcegroup --template-file infra/main.bicep
