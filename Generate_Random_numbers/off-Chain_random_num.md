## Off-chain random number generation

You can generate random numbers off-chain and then upload them to the chain through the oracle.<br>
Chainlink provides ***VRF***(Chainlink Verifiable Random Function) services, and developers on the chain can pay LINK tokens to obtain random numbers.<br>
There are two versions of **Chainlink VRF**. The second version requires registration on the official website and prepayment. It has more operations than the first version and costs more gas,<br>
but you can get the remaining Link back after canceling the subscription. Here we use the second version, Chainlink VRF V2.

### How to use Chainlink VRF

As shown in the following flowchart:
![Chainlink VRF](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Generate_Random_numbers/img/ChainLink_VRF.png)

A simple contract is used to introduce the steps of using **Chainlink VRF**. The **RandomNumberConsumer** contract can request random numbers from VRF and store them in the state variable **randomWords**.

- Step1:

Apply for **Subscription** and transfer **SepoliaETH** tokens as gas fee and some **LINK** as fund:<br>
In [Chinalink VRF](https://vrf.chain.link/), creating a "Subscription", after that transfer 50 **LINK** tokens into **Subscription** as fund<br>
(Testnet's **ETH** and **LINK** tokens could be recevied from [Faucet](https://faucets.chain.link/)).
    - Apply Subscription
![Apply Subscription](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Generate_Random_numbers/img/Subscription_created.png)

    - Add Fund LINK
![Add Fund LINK](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Generate_Random_numbers/img/AddLINKfund.png)

- Step2: User contract inherits **VRFConsumerBaseV2**.

In order to use VRF to obtain random numbers, the contract needs to inherit the **VRFConsumerBaseV2** contract and initialize **VRFCoordinatorV2Interface** and **Subscription Id** in the constructor.<br>
**Note:** Different chains correspond to different parameters, for Sepolia Test Network:
![Sepolia Net Config](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Generate_Random_numbers/img/Sepolia_Testnet_configuration.png)

- Step3:

Users can call the ***requestRandomWords*** function in the **VRFCoordinatorV2Interface** interface contract to request random numbers, and return the request identifier requestId. This request will be passed to the VRF contract(**Note:** After the contract is deployed, you need to add the contract address to the **Consumers** of the **Subscription** before you can send an application).

![Fullfill Consumer address](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Generate_Random_numbers/img/addConsumerAddress.png)

- Step4: The **Chainlink** node generates a random number and *digital signature* off-chain and sends it to the VRF contract.

- Step5: VRF contract verifies signature validity.

- Step6: The user contract receives and uses random numbers.

The user contract receives and uses random numbers. After the VRF contract verifies that the signature is valid, it will automatically call the user contract's fallback function ***fulfillRandomness()*** to send the random number generated off-chain. The user needs to write the logic of consuming the random number here.<br>
**Note:** *requestRandomWords()* called when the user applies for a random number and *fulfillRandomWords()* called when the VRF contract returns a random number are two transactions, called by the user contract and the VRF contract respectively, the latter is a few minutes later than the former (the delay is different for different chains).

## NFT randomly minted by tokenId

Here, we will use on-chain and off-chain random numbers to make an NFT with randomly minted tokenId. The Random contract inherits the ERC721 and VRFConsumerBaseV2 contracts.

### Status Variable

```
- NFT related
    - totalSupply: Total supply of NFT
    - ids: array, used to calculate the tokenId available for minting, see pickRandomUniqueId() function
    - mintCount: the number of mints
- Chainlink VRF related
    - COORDINATOR: return value after calling interface *VRFCoordinatorV2Interface()*
    - vrfCoordinator: VRF contract address
    - keyHash: VRF unique identifier
    - requestConfirmations: Confirmed block number
    - callbackGasLimit: VRF Fees
    - numWords: The number of random numbers requested
    - subId: Subscription Id applied
    - requestId: Application Identifier
    - requestToSender: Records the user address that applies for VRF for minting

  // NFT related<br>
  uint256 public totalSupply = 100;    // Total Supply<br>
  uint256[100] public ids;    // Used to calculate the tokenId that can be minted<br>
  uint256 public mintCount;    // Minted quantity<br>
  
  // Chainlink VRF related parameters
  VRFCoordinatorV2Interface COORDINATOR;
  // Follow Sepolia testnet's configuration
  address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
  bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
  uint16 requestConfirmations = 3;
  uint32 callbackGasLimit = 1_000_000;
  uint32 numWords = 1;
  uint64 subId;
  uint256 public requestId;
  // Record the mint address corresponding to the VRF application identifier
  mapping(uint256 => address) public requestToSender;
  ```

### Constructor function

Usage: Initialize inherited **VRFConsumerBaseV2** and **ERC721** contract's related variables.<br>
```
constructor(uint64 s_subId) {
    VRFConsumerBaseV2(vrfCoordinator)
    ERC721("Rich", "RC"){
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        subId = s_subId;
}
```

### Other functions

In addition to the constructor, 5 functions are defined in the contract.<br>
- ***pickRandomUniqueId()***: Enter a random number to get a tokenId that can be minted.
- ***getRandomOnchain()***: Get the random number on the chain (unsafe).
- ***mintRandomOnchain()***: Uses on-chain random numbers to mint NFTs, calling *getRandomOnchain()* and *pickRandomUniqueId()*.
- ***mintRandomVRF()***: Apply for Chainlink VRF to mint random numbers. Since the logic of using random number minting is in the callback function ***fulfillRandomness()***, and the caller of the callback function is the VRF contract, not the user who minted the NFT, the **requestToSender** state variable must be used here to record the user address corresponding to the VRF application identifier.
- ***fulfillRandomWords()***: VRF callback function, which is automatically called by the VRF contract after verifying the authenticity of the random number, and uses the returned off-chain random number to mint NFT.
<br>

```
/**
 * Input a uint256 number and return a tokenId that can be minted.
 * The algorithm process can be understood as: totalSupply empty cups (ids initialized with 0) are arranged in a row, and a ball is placed next to each cup, numbered [0, totalSupply - 1]
 * Each time, a ball is randomly taken from the field (the ball may be next to the cup, which is the initial state; it may also be in the cup, which means that the ball next to the cup has been taken away,
 * and the new ball is put into the cup from the end)
 * Then put the last ball (which may still be in the cup or next to the cup) into the cup of the ball that was taken away, and repeat totalSupply times. Compared with the traditional random permutation,
 * the gas for initializing ids[] is omitted.
**/
function pickRandomUniqueId(uint256 random) private returns (uint256 tokenId) {
    uint256 len = totalSupply - mintCount++;       // Available mint quantity        
    require(len > 0, "mint close");                // All tokenIds have been minted
    uint256 randomIndex = random % len;            // Get the random number on the chain<br>

    // Take the modulus of the random number to get tokenId as the array index, and record value as len-1.
    // If the value obtained by taking the modulus already exists, tokenId takes the value of the array index.
    tokenId = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;        // Get tokenId
    ids[randomIndex] = ids[len - 1] == 0 ? len - 1 : ids[len - 1];           // Update ids list
    ids[len - 1] = 0;            // Delete the last element and return gas
}
```
```
// On-chain pseudo-random number generation, Convert to uint256 type when returning
// keccak256(abi.encodePacked() fills in some global variables/custom variables on the chain
function getRandomOnchain() public view returns(uint256) {
    // In this case, the on-chain randomness only depends on the block hash, the caller address, and the block time.
    // To improve randomness, you can add some more attributes such as nonce, etc., but this cannot fundamentally solve the security problem.
    bytes32 randomBytes = keccak256(abi.encodePacked(blockhash(block.number-1), msg.sender, block.timestamp));
    return uint256(randomBytes);
}
```
```
// Use on-chain pseudo-random numbers to mint NFTs
function mintRandomOnchain() public {
        uint256 _tokenId = pickRandomUniqueId(getRandomOnchain());    // Generate tokenId using random numbers on the chain
        _mint(msg.sender, _tokenId);
}
```
```
// Call VRF to get random numbers and mint NFT
// To obtain the random number, call the requestRandomness() function. The logic of consuming the random number is written in the VRF callback function fulfillRandomness()
// Before calling, you need to transfer enough Links in Subscriptions
function mintRandomVRF() public {
    // Call requestRandomness to get a random number
    requestId = COORDINATOR.requestRandomWords(
        keyHash,
        subId,
        requestConfirmations,
        callbackGasLimit,
        numWords);
    requestToSender[requestId] = msg.sender;
}
```
```
// VRF callback function, called by VRF Coordinator.
// The logic of consuming random numbers is written in this function.
function fulfillRandomWords(uint256 requestId, uint256[] memory s_randomWords) internal override {
        address sender = requestToSender[requestId];               // Get the minter user address from requestToSender
        uint256 tokenId = pickRandomUniqueId(s_randomWords[0]);    // Generate tokenId using the random number returned by VRF
        _mint(sender, tokenId);
}
```
