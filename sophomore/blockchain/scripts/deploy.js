const { ethers } = require('hardhat');
const { METADATA_URL } = require('../constants');

async function main() {
	const whitelistContract = await ethers.getContractFactory('Whitelist');
	const deployedWhitelistContract = await whitelistContract.deploy(10);

	await deployedWhitelistContract.deployed();

	console.log('Whitelist Contract deployed to:', deployedWhitelistContract.address);
	// Address of the whitelist contract that you deployed in the previous module
	const whitelistCA = deployedWhitelistContract.address;
	// URL from where we can extract the metadata for a Crypto Dev NFT

	console.log('Deploying the CryptoDevs contract...');

	const cryptoDevContract = await ethers.getContractFactory('CryptoDevs');
	const deployedCryptoDevContract = await cryptoDevContract.deploy(METADATA_URL, whitelistCA);

	console.log('NFT Contract deployed to:', deployedCryptoDevContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
