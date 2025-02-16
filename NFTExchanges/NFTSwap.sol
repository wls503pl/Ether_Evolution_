// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/IERC721.sol";
import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/IERC721Receiver.sol";
import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/RCApe.sol";

contract NFTSwap is IERC721Receiver
{
    event List(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price);

    event Purchase(
        address indexed buyer,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price);

    event Revoke(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId);

    event Update(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 newPrice);

    // define Order struct
    struct Order
    {
        address owner;
        uint256 price;
    }

    // NFT Order mapping
    mapping(address => mapping(uint256 => Order)) public nftList;

    fallback() external payable {}

    // // Order: The seller lists NFT, the contract address is _nftAddr,
    // the tokenId is _tokenId, and the price _price is Ethereum (in wei)
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 _nft = IERC721(_nftAddr);   // declare IERC721 interface contract variable
        require(_nft.getApproved(_tokenId) == address(this), "Need Approval");  // Contract authorized
        require(_price > 0);    // price is higher than 0

        Order storage _order = nftList[_nftAddr][_tokenId]; // Setting NFT holders and prices
        _order.owner = msg.sender;
        _order.price = _price;
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        // release List Event
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    // Buy: Buyer buy NFT, contract is _nftAddr, tokenId is _tokenId, ETH is required when calling function
    function purchase(address _nftAddr, uint256 _tokenId) public payable
    {
        Order storage _order = nftList[_nftAddr][_tokenId]; // acquire Order
        require(_order.price > 0, "Invalid Price");         // NFT's price is higher than 0
        require(msg.value >= _order.price, "Increase price");   // Purchase price is greater than the listed price
        IERC721 _nft = IERC721(_nftAddr);           // Declare IERC721 interface contract variables
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");  // NFT in the contract

        // transfer NFT to buyer
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        // transfer ETH to deller
        payable(_order.owner).transfer(_order.price);

        // Excess ETH will be refunded to the buyer
        if (msg.value > _order.price)
        {
            payable(msg.sender).transfer(msg.value - _order.price);
        }

        // release Purchase event
        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);

        delete nftList[_nftAddr][_tokenId];         // delete order
    }

    // Revoke, Seller cancels order
    function revoke(address _nftAddr, uint256 _tokenId) public
    {
        Order storage _order = nftList[_nftAddr][_tokenId];     // acquire Order
        require(_order.owner == msg.sender, "Not Owner");       // Must be initiated by the holder
        IERC721 _nft = IERC721(_nftAddr);           // Declare IERC721 interface contract variables
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");  // NFT in the contract

        // Transfer the NFT to the seller
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId];         // delete order

        emit Revoke(msg.sender, _nftAddr, _tokenId);    // release revoke event
    }

    // Update price: seller update list price
    function update(
        address _nftAddr,
        uint256 _tokenId,
        uint256 _newPrice
    ) public {
        require(_newPrice > 0, "Invalid Price");  // NFT's price is higher than 0
        Order storage _order = nftList[_nftAddr][_tokenId];     // acquire Order
        require(_order.owner == msg.sender, "Not Owner");       // Must be initiated by the holder
        IERC721 _nft = IERC721(_nftAddr);       //Declare IERC721 interface contract variables
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");  // NFT in the contract

        // Adjusting NFT prices
        _order.price = _newPrice;

        // Release Update event
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }

    // Implement onERC721Received of {IERC721Receiver} to receive ERC721 tokens
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override returns(bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }
}
