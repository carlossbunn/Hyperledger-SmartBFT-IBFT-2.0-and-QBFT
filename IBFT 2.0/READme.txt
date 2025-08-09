Just like in the repository of  https://github.com/prasanthdotv/besu-ibft2-private-blockchain
Clone repo
Go to ./genesis-generator
Make changes in ibftConfigFile.json as your preference
Run docker-compose up. Genesis file and key pairs will be generated.
Copy the genesis file to each node folder.
Copy one key pair for each node and place it in the data/
Run docker-compose up -d on root level of working directory.
From the logs of bootnode (node-1) copy the enode url and add it to the config.toml for all other nodes.
TO START restart all the containers.

I make some changes in the ibftconfig file, looking for have more accounts.
