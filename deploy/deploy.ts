import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const voting = await deploy("FHVoting", {
    from: deployer,
    args: ["question?", ["yes", "no"]],
    log: true,
    skipIfAlreadyDeployed: false,
  });

  console.log(`FHVoting contract: `, voting.address);

  const counter = await deploy("Counter", {
    from: deployer,
    args: [],
    log: true,
    skipIfAlreadyDeployed: false,
  });

  console.log(`Counter contract: `, counter.address);
};

export default func;
func.id = "deploy_voting";
func.tags = ["FHVoting"];
