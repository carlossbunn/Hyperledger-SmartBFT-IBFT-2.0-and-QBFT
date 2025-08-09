


**This is just a base initialization of the Hyperledger Besu network using 4 nodes and QBFT on a single server.**

generate-network-docker-compose.yml:
Generates networkFiles, which contain configuration for the genesis block, as well as public and private keys for each node based on qbftConfigFile.json.
(As of now, a sample structure is provided. If needed, run the following command to regenerate the files):
docker compose -f generate-network-docker-compose.yml up -d



start-network-docker-compose.yml:
Starts the network consisting of 4 nodes, with one node acting as a boot node to establish connections between peers.

**To start the network, run:**


docker compose -f start-network-docker-compose.yml up -d

**To stop the network, run:**

docker compose -f start-network-docker-compose.yml down -d
