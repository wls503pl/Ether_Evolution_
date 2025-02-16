// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomNumberConsumer is VRFConsumerBaseV2
{
    // request random number needs to call interface "VRFCoordinatorV2Interface"
    VRFCoordinatorV2Interface COORDINATOR;

    // subscription Id after request
    uint64 subId;

    // store the obtained requestId and random number
    uint256 public requestId;
    uint256[] public randomWords;

    /**
     * When using chainlink VRF, the constructor needs to inherit VRFConsumerBaseV2
     * Different chain parameters are filled in differently.
     * For details, please see: https://docs.chain.link/vrf/v2/subscription/supported-networks
     * Chainlink VRF Coordinator address: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
     * LINK token's address: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * 30 gwei Key Hash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c
     * Minimum Confirmations: 3 (larger numbers mean higher security, usually 12)
     * callbackGasLimit gas limit: maximum 2,500,000
     * Maximum Random Values ​​The number of random numbers that can be obtained at one time: Maximum 500
     **/
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 200_000;
    uint32 numWords = 3;

    constructor(uint64 s_subId) VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        subId = s_subId;
    }

    // Request random number from VRF contract
    function requestRandomWords() external
    {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subId,
            requestConfirmations,
            callbackGasLimit,
            numWords 
        );
    }

    // VRF contract's callback function, called automatically after verifying that random number is OK
    // The logic of consuming random numbers is written here
    function fulfillRandomWords(uint256 requestId, uint256[] memory s_randomWords) internal override {
        randomWords = s_randomWords;
    }
}
