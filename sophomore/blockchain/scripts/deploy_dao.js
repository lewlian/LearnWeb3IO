const { ethers } = require('hardhat');
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require('../constants');

async function main() {
	const fakeNFTMarketplace = await ethers.getContractFactory('FakeNFTMarketplace');
	const deployedFakeNFTMarketplace = await fakeNFTMarketplace.deploy();
	await deployedFakeNFTMarketplace.deployed();
	console.log('CryptoDevsDAO Contract deployed to:', deployedFakeNFTMarketplace.address);

	const daoContract = await ethers.getContractFactory('CryptoDevsDAO');
	const deployedDaoContract = await daoContract.deploy(deployedFakeNFTMarketplace.address, CRYPTO_DEVS_NFT_CONTRACT_ADDRESS, {
		value: ethers.utils.parseEther('1'),
	});

	await deployedDaoContract.deployed();

	console.log('CryptoDevsDAO Contract deployed to:', deployedDaoContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
