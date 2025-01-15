// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/ERC721.sol";

contract DutchAuction is Ownable, ERC721
{
	// NFT total quantity
    uint256 public constant COLLECTION_SIZE = 10000;

    // Starting Price
    uint256 public constant AUCTION_START_PRICE = 1 ether;

    // End price (lowest price)
    uint256 public constant AUCTION_END_PRICE = 0.1 ether;

    // The auction time is set to 10 minutes for testing purposes
    uint256 public constant AUCTION_TIME = 10 minutes;

    // How long does it take for the price to decay?
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes;

	// Each price decay step
    uint256 public constant AUCTION_DROP_PER_STEP = 
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
        (AUCTION_TIME / AUCTION_DROP_INTERVAL);

 	// Auction start timestamp
    uint256 public auctionStartTime;

    //  metadata URI
    string private _baseTokenURI;

    // Record all existing tokenIds
    uint256[] private _allTokens;

 	// Set the auction start time: declare the current block time as the start time in the constructo
  	// The project owner can also adjust it through the 'setAuctionStartTime(uint32)' function
   	construct() Ownable(msg.sender) ERC721("Rich", "RC")
	{
 		auctionStartTime = block.timestamp;
 	}

  	// Implementation of totalSupply function in ERC721Enumerable
    function totalSupply() public view virtual returns(uint256)
    {
        return _allTokens.length;
    }

 	// Private function, add a new token in _allTokens
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private 
    {
        _allTokens.push(tokenId);
    }

 	// Auction mint function
    function auctionMint(uint256 quantity) external payable
    {
    	// Create local variables to reduce gas costs
        uint256 _saleStartTime = uint256(auctionStartTime);

        // Check whether the start time is set and whether the auction has started
        require(
            _saleStartTime != 0 && block.timestamp >= _saleStartTime,
            "sale has not started yet"
        );

  		// Check whether the NFT limit is exceeded
        require(
            totalSupply() + quantity <= COLLECTION_SIZE,
            "not enough remaining reserved for auction to support desired mint amount"
        );

        // Calculate mint cost
        uint256 totalCost = getAuctionPrice() * quantity;

        // Check if the user has paid enough ETH
        require(msg.value >= totalCost, "Need to send more ETH.");

        // Mint NFT
        for (uint256 i = 0; i < quantity; i++)
        {
            uint256 mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }

  		// Excess ETH Refund
        if (msg.value > totalCost)
        {
            // @notice: whether there is a risk of re-entry.
            payable(msg.sender).transfer(msg.value - totalCost);
        }
	}

 	// Get real-time auction prices
    function getAuctionPrice() public view returns(uint256)
    {
        if (block.timestamp < auctionStartTime)
        {
            return AUCTION_START_PRICE;
        }

        else if (block.timestamp - auctionStartTime >= AUCTION_TIME)
        {
            return AUCTION_END_PRICE;
        }
        else
        {
            uint256 steps = (block.timestamp - auctionStartTime) / AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

 	/**
     * Auction start time setter function, onlyOwner: This is a function modifier.
     * The onlyOwner modifier is usually defined in Ownable contracts to ensure that only authorized users
     * (usually the deployer or current owner of the contract) can perform certain actions.
     **/
    function setAuctionStartTime(uint32 timestamp) external onlyOwner
    {
        auctionStartTime = timestamp;
    }

    // BaseURI
    function _baseURI() internal view virtual override returns(string memory)
    {
        _baseTokenURI;
    }

    // BaseURI setter function, onlyOwner
    function setBaseURI(string calldata baseURI) external onlyOwner
    {
        _baseTokenURI = baseURI;
    }

 	// Withdrawal function, onlyOwner
    function withdrawMoney() external onlyOwner
    {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
