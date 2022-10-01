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
      accounts: ['0xabae157b7941badaa0f9c668cd354dcde70d4c94575198bd433839d0f24a43a1']
    }
  }
};

export default config;
