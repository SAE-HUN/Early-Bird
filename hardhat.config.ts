import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      forking: {
        url: 'https://polygon-rpc.com'
      }
    },
    klaytn: {
      url: 'https://api.baobab.klaytn.net:8651',
      accounts: []
    }
  }
};

export default config;
