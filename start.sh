docker-compose -f ./artifacts/channel/create-certificate-with-ca/docker-compose.yaml up -d
docker-compose -f ./artifacts/docker-compose.yaml up -d

sleep 30
./createChannel.sh

sleep 2

./deployChaincode.sh
