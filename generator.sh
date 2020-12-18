#!/bin/bash
# Start container at port 8888 and save the container id
CID=$(docker run -d -p 8888:8080 openapitools/openapi-generator-online)
echo "Wait 20 seconds for server to start"
# allow for startup
sleep 20
# Get the IP of the running container (optional)
GEN_IP=$(docker inspect --format '{{.NetworkSettings.IPAddress}}'  ${CID})
echo "IP of running container ${GEN_IP} (${CID})"
# Execute an HTTP request to generate a Ruby client
CURL_RESPONSE=$(curl -X POST --header 'Content-Type: application/json' --silent --header 'Accept: application/json' -d '{"openAPIUrl": "https://gateway.pix.fr/swagger.json"}' 'http://localhost:8888/api/gen/clients/java')
echo "Curl response: ${CURL_RESPONSE}"
ZIP_FILE=$(echo ${CURL_RESPONSE} | sed -E 's/.*"code":"?([^,"]*)"?.*/\1/')

# Example output:
# {"code":"c2d483.3.4672-40e9-91df-b9ffd18d22b8","link":"http://localhost:8888/api/gen/download/c2d483.3.4672-40e9-91df-b9ffd18d22b8"}
# Download the generated zip file  (using "code" provided from your output)
echo "Download ${ZIP_FILE}"
wget http://localhost:8888/api/gen/download/${ZIP_FILE}
# Unzip the file
unzip ${ZIP_FILE}
echo "Project generated in java-client folder"
# Shutdown the openapi generator image
docker stop ${CID} && docker rm ${CID}
