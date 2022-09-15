import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  namedAccounts: {
    deployer: 0,
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
  },
};

export default config;
