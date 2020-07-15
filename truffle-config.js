const HDWalletProvider = require('@truffle/hdwallet-provider');
const dotenv = require('dotenv');

dotenv.config();

module.exports = {
	contracts_build_directory: './client/contracts',
	networks: {
		development: {
			host: 'localhost',
			port: 8545,
			network_id: '*' // Match any network id
		},
		ropsten: {
			provider: () => new HDWalletProvider(process.env.ROPSTEN_MNEMONIC, process.env.ROPSTEN_WEB3),
			network_id: 3, // Ropsten's id
			gas: 5500000, // Ropsten has a lower block limit than mainnet
			confirmations: 1, // # of confs to wait between deployments. (default: 0)
			timeoutBlocks: 50, // # of blocks before a deployment times out  (minimum/default: 50)
			skipDryRun: true // Skip dry run before migrations? (default: false for public nets )
		}
	},
	compilers: {
		solc: {
			version: '^0.4.23', // A version or constraint - Ex. "^0.5.0"
			// Can also be set to "native" to use a native solc
			parser: 'solcjs' // Leverages solc-js purely for speedy parsing
		}
	}
};
