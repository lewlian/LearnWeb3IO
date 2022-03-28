const { ethers } = require('hardhat');

async function main() {
	const nftContract = await ethers.getContractFactory('GameItem');

	const deployedNFTContract = await nftContract.deploy();

	console.log('NFT Contract Address:', deployedNFTContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
