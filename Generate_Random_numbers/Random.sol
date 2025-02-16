// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Random is ERC721, VRFConsumerBaseV2
{
    // NFT related
    uint256 public totalSupply = 100;   // total supply
    uint256[100] public ids;            // used to calculate the tokenId that can be minted
    uint256 public mintCount;           // amount that has been minted

    // chainlink VRF parameter

    // VRFCoordinatorV2Interface
    VRFCoordinatorV2Interface COORDINATOR;

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
    uint64 subId;    // subscription Id after request
    uint256 public requestId;

    // Record the mint address corresponding to the VRF application identifier
    mapping(uint256 => address) public requestToSender;

    constructor(uint64 s_subId) VRFConsumerBaseV2(vrfCoordinator) ERC721("Rich", "RC")
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        subId = s_subId;
    }

    // Input a uint256 number and return a tokenId that can be minted
    function pickRandomUniqueId(uint256 random) private returns(uint256 tokenId)
    {
        uint256 len = totalSupply - mintCount++;    // Mint quantity
        require(len > 0, "mint close");             // All tokenIds have been minted
        uint256 randomIndex = random % len;         // Get random number on the chain

        // Take the random number modulo as the array subscript to get tokenId, and record value as len-1
        // If the value obtained by modulo already exists, tokenId takes the value of the array subscript
        tokenId = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;   // Get tokenId
        ids[randomIndex] = ids[len - 1] == 0 ? len - 1 : ids[len - 1];      // Update the ids list
        ids[len - 1] = 0;   // Deleting the last element can return gas
    }

    /**
     * On-chain pseudo-random number generation
     * keccak256(abi.encodePacked() fills in some global variables/custom variables on the chain
     * Convert to uint256 type when returning
     **/
    function getRandomOnchain() public view returns(uint256) {
        /**
         * In this case, the on-chain randomness only depends on the block hash, the caller address, and the block time.
         * To improve randomness, you can add some more attributes such as nonce, etc.,
         * but this cannot fundamentally solve the security problem.
         **/
        bytes32 randomBytes = keccak256(abi.encodePacked(blockhash(block.number-1), msg.sender, block.timestamp));
        return uint256(randomBytes);
    }

    // Using on-chain pseudo-random numbers to mint NFTs
    function mintRandomOnchain() public {
        uint256 _tokenId = pickRandomUniqueId(getRandomOnchain());  // Generate tokenId using random numbers on the chain
        _mint(msg.sender, _tokenId);
    }

    /**
     * Call VRF to get random numbers and mint NFT
     * To obtain the random number, call the requestRandomness() function.
     * The logic of consuming the random number is written in the VRF callback function fulfillRandomness()
     * Before calling, you need to fund enough Link in Subscriptions
     **/
    function mintRandomVRF() public {
        //Call requestRandomness to get a random number
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        requestToSender[requestId] = msg.sender;
    }

    /**
     * VRF callback function, called by VRF Coordinator
     * The logic of consuming random numbers is written in this function
     **/
    function fulfillRandomWords(uint256 requestId, uint256[] memory s_randomWords) internal override {
        address sender = requestToSender[requestId];    // Get the minter user address from requestToSender
        uint256 tokenId = pickRandomUniqueId(s_randomWords[0]);     // Generate tokenId using the random number returned by VRF
        _mint(sender, tokenId);
    }
}
