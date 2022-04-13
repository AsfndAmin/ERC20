require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
    },
  },
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_API_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
    bsc: {
      url: process.env.BSC_API_KEY,
      accounts: [process.env.PRIVATE_KEY],
      confirmation: 4,
    },
  },
  etherscan: {
    apiKey: process.env.ETHER_KEY,
  },
};
