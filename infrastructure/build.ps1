# Set the necessary variables
$PROJECT_FOLDER = (Get-Location).Path + "\.."
$INFRA_FOLDER = (Get-Location).Path
$SCA_FOLDER = (Get-Location).Path + "\sca"
$BONITA_ENVIRONMENT = "presales"

# Cleanup
docker-compose -f "$SCA_FOLDER\docker-compose.yml" --env-file "$SCA_FOLDER\.env-local" -p bonita_sca down -v
docker image rm bonita_sca:1.0

# Build
Set-Location -Path $PROJECT_FOLDER
mvn bonita-project:install
mvn clean package -P docker -D bonita.environment=$BONITA_ENVIRONMENT -D docker.baseImageRepository=bonitasoft.jfrog.io/docker-releases/bonita-subscription -D docker.imageName=bonita_sca:1.0

# Start
docker-compose -f "$SCA_FOLDER\docker-compose.yml" --env-file "$SCA_FOLDER\.env-local" -p bonita_sca up -d

## Wait for the server to start
#& "$INFRA_FOLDER\healthz.sh"

## Run tests
#Set-Location -Path "$PROJECT_FOLDER\IT"
#./mvnw clean verify -f "$PROJECT_FOLDER\IT\pom.xml" -Dbonita.url=http://localhost:8090/bonita
