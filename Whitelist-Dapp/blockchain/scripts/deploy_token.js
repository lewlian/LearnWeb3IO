const { ethers } = require('hardhat');
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require('../constants');

async function main() {
	const tokenContract = await ethers.getContractFactory('CryptoDevToken');
	const deployedTokenContract = await tokenContract.deploy(CRYPTO_DEVS_NFT_CONTRACT_ADDRESS);

	await deployedTokenContract.deployed();

	console.log('CryptoDevToken Contract deployed to:', deployedTokenContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
