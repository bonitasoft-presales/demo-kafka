#!/usr/bin/env sh

PROJECT_FOLDER="${PWD}/.."
INFRA_FOLDER="${PWD}"
SCA_FOLDER="${PWD}/sca"
BONITA_ENVIRONMENT="showroom"
ENV_FILE=${SCA_FOLDER}/.env-local-laurent

# cleanup
docker compose -f ${SCA_FOLDER}/docker-compose.yml --env-file ${ENV_FILE} -p bonita_sca down -v
docker image rm bonita_sca:1.0

#build
cd ${PROJECT_FOLDER} || exit
./mvnw bonita-project:install
./mvnw clean package \
-Pdocker \
-Dbonita.environment=${BONITA_ENVIRONMENT} \
-Ddocker.baseImageRepository=bonitasoft.jfrog.io/docker-releases/bonita-subscription \
-Ddocker.imageName=bonita_sca:1.0

#start
docker compose -f ${SCA_FOLDER}/docker-compose.yml --env-file ${ENV_FILE} -p bonita_sca up -d

#wait server started
${INFRA_FOLDER}/healthz.sh



#run tests
# skip: error with JFAIRY and java 17
#${PROJECT_FOLDER}/IT
#./mvnw clean verify -f ${PROJECT_FOLDER}/IT/pom.xml -Dbonita.url=http://localhost:8085/bonita