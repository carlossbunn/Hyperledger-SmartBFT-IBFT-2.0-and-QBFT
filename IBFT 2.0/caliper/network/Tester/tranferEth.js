'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class EthTransferWorkload extends WorkloadModuleBase {
    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {

        this.web3 = sutContext.web3;
        this.fromAccount = sutContext.fromAddress;
        this.toAccount = roundArguments.toAccount;
        this.value = this.web3.utils.toWei(roundArguments.valueEther || '0.001', 'ether'); // valor a enviar
    }

    async submitTransaction() {
        // transação 
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

