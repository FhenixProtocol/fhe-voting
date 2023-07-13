import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { waitForBlock } from "../utils/block";
import { createFheInstance } from "../utils/instance";

task("task:init")
  .addParam("account", "Specify which account [0, 9]")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const { ethers, deployments } = hre;

    const Voting = await deployments.get("FHVoting");

    const signers = await ethers.getSigners();

    const voting = await ethers.getContractAt("FHVoting", Voting.address);

    console.log(`contract at: ${Voting.address}, for signer: ${signers[taskArguments.account].address}`);

    await voting.connect(signers[Number(taskArguments.account)]).init();

    await waitForBlock(hre);

    console.log(`Initialized the contract!`);
  });
