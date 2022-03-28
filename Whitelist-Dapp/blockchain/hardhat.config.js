require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-etherscan');
require('dotenv').config({ path: '.env' });

const INFURA_API_KEY_URL = process.env.INFURA_API_KEY_URL;
const RINKEBY_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

module.exports = {
	solidity: '0.8.10',
	networks: {
		rinkeby: {
			url: INFURA_API_KEY_URL,
			accounts: [RINKEBY_PRIVATE_KEY],
		},
	},
	etherscan: {
		// Your API key for Etherscan
		// Obtain one at https://etherscan.io/
		apiKey: ETHERSCAN_API_KEY,
	},
};
