jsut like in : https://github.com/credaegis-enterprise/credaegis-hyperledeger-besu
This repository provides a basic configuration to initialize a Hyperledger Besu network with 4 nodes using the QBFT (Quorum Byzantine Fault Tolerance) consensus on a single server. This setup is ideal for development and testing purposes.
Repository Structure

    boot-node/: Contains configuration files for the boot node, responsible for establishing connections between peers in the network.
    node-1/, node-2/, node-3/: Directories containing specific configurations for each of the three additional participating nodes.
    .gitignore: File specifying which files or folders should be ignored by Git.
    generate-network-docker-compose.yml: Docker Compose file used to generate the network configuration files, including the genesis block and each node's public and private keys, based on qbftConfigFile.json.
    qbftConfigFile.json: Configuration file defining the parameters for the QBFT consensus.
    start-network-docker-compose.yml: Docker Compose file used to start the network with the 4 configured nodes.

Steps to Configure and Initialize the Network

    Clone the Repository

git clone https://github.com/credaegis-enterprise/credaegis-hyperledeger-besu.git
cd credaegis-hyperledeger-besu

Generate the Network Configuration Files





The generate-network-docker-compose.yml file is used to generate the necessary files for the network configuration, such as the genesis block and each node's keys.

docker compose -f generate-network-docker-compose.yml up -d

This command will generate the configuration files based on qbftConfigFile.json. Ensure that the qbftConfigFile.json file is properly configured according to the desired parameters for the QBFT consensus.

Start the Network

After generating the configuration files, use the start-network-docker-compose.yml file to start the network with the 4 nodes.

docker compose -f start-network-docker-compose.yml up -d

This command will start the defined nodes (boot-node, node-1, node-2, node-3) and establish the network using the QBFT consensus.

Verify the Network Status

To check if the containers are running and the network has started correctly, use:

docker ps

Ensure that all nodes are listed and running.
