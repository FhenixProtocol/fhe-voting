// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity >=0.8.13 <0.9.0;

import "fhevm/lib/TFHE.sol";

contract FHVoting {
    string public query;
    string public option1;
    string public option2;

    euint32 option1Tally;
    euint32 option2Tally;

    uint32 MAX_INT = 2 ** 32 - 1;

    mapping(address => euint32) internal votes;

    constructor(string memory q, string memory opt1, string memory opt2) {
        query = q;
        option1 = opt1;
        option2 = opt2;
    }

    function init() public {
        option1Tally = TFHE.asEuint32(0);
        option2Tally = TFHE.asEuint32(0);
    }

    function vote(bytes memory encOption) public {
        euint32 option = TFHE.asEuint32(encOption);

        TFHE.req(TFHE.or(TFHE.eq(option, TFHE.asEuint32(1)), TFHE.eq(option, TFHE.asEuint32(2))));

        // If already voted - first revert the old vote
        if (TFHE.isInitialized(votes[msg.sender])) {
            addToTally(votes[msg.sender], TFHE.asEuint32(MAX_INT)); // Adding MAX_INT is effectively `.sub(1)`
        }

        votes[msg.sender] = option;
        addToTally(option, TFHE.asEuint32(1));
    }

    function getOpt1Tally(bytes32 publicKey) public view returns (bytes memory) {
        return TFHE.reencrypt(option1Tally, publicKey);
    }

    function getOpt2Tally(bytes32 publicKey) public view returns (bytes memory) {
        return TFHE.reencrypt(option2Tally, publicKey);
    }

    function addToTally(euint32 option, euint32 eAmount) internal {
        // if (option == 1) return eAmount else return 0
        euint32 opt1Add = TFHE.cmux(TFHE.eq(option, TFHE.asEuint32(1)), eAmount, TFHE.asEuint32(0));

        // if (option == 2) return eAmount else return 0
        euint32 opt2Add = TFHE.cmux(TFHE.eq(option, TFHE.asEuint32(2)), eAmount, TFHE.asEuint32(0));

        option1Tally = TFHE.add(option1Tally, opt1Add);
        option2Tally = TFHE.add(option2Tally, opt2Add);
    }
}
