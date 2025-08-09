Prerequisites

    Node.js: Ensure that Node.js is installed. Version 14 LTS is recommended for compatibility with Caliper 0.5.0.
    NPM: The Node.js package manager should be available.
    Hyperledger Besu: A properly configured and running Besu network.

Installing Hyperledger Caliper

    Install the Caliper CLI:

npm install --only=prod @hyperledger/caliper-cli@0.5.0 -g

Verify the installation:

npx caliper --version

Bind Caliper to Hyperledger Besu:

    npx caliper bind --caliper-bind-sut besu:latest

    This command installs the necessary dependencies for Caliper to interact with Besu.

Configuring the Besu Network

Ensure that your Besu network is correctly configured and that the RPC endpoints are accessible. For example, the HTTP RPC might be available at http://localhost:8545, and WebSocket at ws://localhost:8546. Verify that the accounts used for transactions have sufficient balance and that the chainId is correctly set in the network's genesis file.
Setting Up Caliper

Network Configuration File (networkconfig.json):
This file defines how Caliper connects to the Besu network. Example:

Replace 0xYOUR_ADDRESS and YOUR_PRIVATE_KEY with your account's corresponding values.

Workload File (transferEth.js):

This script defines the behavior of the transactions to be sent during the benchmark. Example:

'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class EthTransferWorkload extends WorkloadModuleBase {
    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        this.web3 = sutContext.web3;
        this.fromAccount = sutContext.fromAddress;
        this.toAccount = roundArguments.toAccount;
        this.value = this.web3.utils.toWei(roundArguments.valueEther || '0.001', 'ether');
    }

    async submitTransaction() {
        const tx = {
            from: this.fromAccount,
            to: this.toAccount,
            value: this.value,
            gas: 21000,
            gasPrice: await this.web3.eth.getGasPrice()
        };
        await this.web3.eth.sendTransaction(tx);
    }
}

function createWorkloadModule() {
    return new EthTransferWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;

Benchmark Configuration File is in config.yaml:



To start the benchmark, execute the following command in the project's root directory:

npx caliper launch manager \
  --caliper-workspace . \
  --caliper-benchconfig benchmarks/scenario/simple/config.yaml \
  --caliper-networkconfig networks/besu/ibft-network/networkconfig.json \
  --caliper-flow-skip-end

This command initiates the benchmark based on the provided configurations. 
