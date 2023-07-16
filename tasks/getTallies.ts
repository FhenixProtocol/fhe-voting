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
    const tally = await voting.connect(signers[taskArguments.account]).getTally(publicKey); //.getOpt1Tally(publicKey);

    for (var i = 0; i < tally.length; i++) {
      console.log(`Option ${i} tally: `, instance.decrypt(FHVoting.address, tally[i]));
    }
  });
