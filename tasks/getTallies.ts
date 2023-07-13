import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { createFheInstance } from "../utils/instance";

task("task:getTallies")
  .addParam("account", "Specify which account [0, 9]")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const { ethers, deployments } = hre;

    const FHVoting = await deployments.get("FHVoting");

    const signers = await ethers.getSigners();

    const voting = await ethers.getContractAt("FHVoting", FHVoting.address);

    const { instance, publicKey } = await createFheInstance(hre, FHVoting.address);
    const eOpt1Tally = await voting.connect(signers[taskArguments.account]).getOpt1Tally(publicKey);
    let tally = instance.decrypt(FHVoting.address, eOpt1Tally);
    console.log("Option 1 tally: ", tally);

    const eOpt2Tally = await voting.connect(signers[taskArguments.account]).getOpt2Tally(publicKey);
    tally = instance.decrypt(FHVoting.address, eOpt2Tally);
    console.log("Option 2 tally: ", tally);
  });
