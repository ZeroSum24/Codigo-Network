const webTrust = artifacts.require('./webTrust.sol');

module.exports = function(deployer, network) {
	if (network == 'ropsten') {
		deployer.deploy(webTrust);
	} else {
		// Perform a different step otherwise.
	}
};
