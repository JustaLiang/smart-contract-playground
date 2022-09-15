import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deploy } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();
  await deploy("ERC721AntiRugPullMock", {
    from: deployer,
    log: true,
  });
};
export default func;
func.tags = ["ERC721AntiRugPull"];