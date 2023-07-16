// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity >=0.8.13 <0.9.0;

import "fhevm/lib/TFHE.sol";

contract FHVoting {
    string public query;

    string[] public options;
    euint8[] internal encOptions;

    uint32 MAX_INT = 2 ** 32 - 1;
    uint8 MAX_OPTIONS = 5;

    mapping(address => euint8) internal votes;
    mapping(uint8 => euint32) internal tally;

    constructor(string memory q, string[] memory optList) {
        require(optList.length <= MAX_OPTIONS, "too many options!");

        query = q;
        options = optList;
    }

    function init() public {
        for (uint8 i = 0; i < options.length; i++) {
            tally[i] = TFHE.asEuint32(0);
            encOptions.push(TFHE.asEuint8(i));
        }
    }

    function vote(bytes memory encOption) public {
        euint8 option = TFHE.asEuint8(encOption);

        // This is probably not needed
        // require(encOptions.contains(option))
        euint8 isValid = TFHE.or(TFHE.eq(option, encOptions[0]), TFHE.eq(option, encOptions[1]));
        for (uint i = 1; i < encOptions.length; i++) {
            TFHE.or(isValid, TFHE.eq(option, encOptions[i + 1]));
        }
        TFHE.req(isValid);

        // If already voted - first revert the old vote
        if (TFHE.isInitialized(votes[msg.sender])) {
            addToTally(votes[msg.sender], TFHE.asEuint32(MAX_INT)); // Adding MAX_INT is effectively `.sub(1)`
        }

        votes[msg.sender] = option;
        addToTally(option, TFHE.asEuint32(1));
    }

    function getTally(bytes32 publicKey) public view returns (bytes[] memory) {
        bytes[] memory tallyResp = new bytes[](encOptions.length);
        for (uint8 i = 0; i < encOptions.length; i++) {
            tallyResp[i] = (TFHE.reencrypt(tally[i], publicKey));
        }

        return tallyResp;
    }

    function addToTally(euint8 option, euint32 amount) internal {
        for (uint8 i = 0; i < encOptions.length; i++) {
            euint32 toAdd = TFHE.cmux(TFHE.asEuint32(TFHE.eq(option, encOptions[i])), amount, TFHE.asEuint32(0));
            tally[i] = TFHE.add(tally[i], toAdd);
        }
    }
}
