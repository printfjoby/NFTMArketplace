require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

const INFURA_API_KEY = process.env.INFURA_API_KEY;

const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.18", 
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
    paths: {
      artifacts: "./artifacts",
    },
    networks: {
      sepolia: {
        url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
        accounts: [SEPOLIA_PRIVATE_KEY]
      }
    },
    external: {
      contracts: [
        {
          artifacts: "@openzeppelin/contracts/build/contracts",
        },
      ],
    },
  },
};


