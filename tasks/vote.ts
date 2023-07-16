import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { waitForBlock } from "../utils/block";
import { createFheInstance } from "../utils/instance";

task("task:vote")
  .addParam("option", "number: 1 or 2")
  .addParam("account", "Specify which account [0, 9]")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const { ethers, deployments } = hre;

    const Voting = await deployments.get("FHVoting");

    const signers = await ethers.getSigners();

    const voting = await ethers.getContractAt("FHVoting", Voting.address);

    console.log(`contract at: ${Voting.address}, for signer: ${signers[taskArguments.account].address}`);

    const { instance } = await createFheInstance(hre, Voting.address);
    const eVote = instance.encrypt8(Number(taskArguments.option));

    await voting.connect(signers[Number(taskArguments.account)]).vote(eVote);

    await waitForBlock(hre);

    console.log(`Voted to option ${taskArguments.option}!`);
  });
