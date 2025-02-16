## Logic of Design

Seller: The party selling NFT can list, revoke, and update the price.<br>
Buyer: The party who purchases NFT can purchase.<br>
Order: The NFT chain order issued by the seller, there is at most one order for the same tokenId in a series, which contains the price of the pending order and the owner information. When an order transaction is completed or cancelled, the information is cleared.

### NFT Contract

- Event<br>
The contract contains 4 events, corresponding to the following four actions: order list, order revoke, price update, and purchase:<br>
<hr>
event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);<br>
event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);<br>
event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newPrice);<br>
event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);<br>
<hr>

### Order

NFT orders are abstracted into Order structures, which contain the order price and owner information. nftList maps and records the order’s corresponding NFT series (contract address) and tokenId information.
<hr>
// Define Order struct<br>
struct Order<br>
{<br>
  address owner;<br>
  uint256 price;<br>
}<br>
<br>
// NFT Order mapping<br>
mapping(address => mapping(uint256 => Order)) public nftList;<br>
<hr>

- Fallback function<br>

In NFTSwap, users use ETH to purchase NFTs. Therefore, the contract needs to implement the fallback() function to receive ETH.
<hr>
fallback external payable{}<br>
<hr>

- 'onERC721Received' function<br>

The ERC721 secure transfer function will check whether the receiving contract implements the ***onERC721Received()*** function, and return the correct selector.<br>
After the user places an order, the NFT needs to be sent to the NFTSWAP contract. Therefore, NFTSWAP inherits the ***IERC721Receiver*** interface and implements the ***onERC721Received()*** function.
<hr>
contract NFTSwap is IERC721Receiver {<br>
  // Implement onERC721Received of {IERC721Receiver} to receive ERC721 tokens<br>
  function onERC721Received(<br>
    address operator,<br>
    address from,<br>
    uint tokenId,<br>
    bytes calldata data<br>
  ) external override returns (bytes4)<br>
  {<br>
    return IERC721Receiver.onERC721Received.selector;<br>
  }<br>
<hr>

### Exchange

The contract implements 4 transaction-related functions:<br>

- List(): The seller creates an NFT and an order, and releases the List event. The parameters are the NFT contract address **_nftAddr**, the NFT token ID **_tokenId**,
  and the order price **_price** (note: the unit is wei). After success, the NFT will be transferred from the seller to the NFTSwap contract.
<hr>
// Order: The seller lists NFT, the contract address is _nftAddr, the tokenId is _tokenId, and the price _price is Ethereum (in wei)<br>
function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {<br>
  IERC721 _nft = IERC721(_nftAddr);      // Declare IERC721 interface contract variables<br>
  require(_nft.getApproved(_tokenId) == address(this), "Need Approval");      // Contract authorized<br>
  require(_price > 0);      // Price is more than 0<br>

  Order storage _order = nftList[_nftAddr][_tokenId];      // set NFT holder and price<br>
  _order.owner = msg.sender;<br>
  _order.price = _price;<br>

  _nft.safeTransferFrom(msg.sender, address(this), _tokenId);<br>
  emit List(msg.sender, _nftAddr, _tokenId, _price);      // release List event<br>
}<br>

### Revoke

The seller withdraws the order and releases the Revoke event. The parameters are the NFT contract address _nftAddr and the NFT corresponding _tokenId.<br>
If successful, the NFT will be transferred back to the seller from the NFTSwap contract.<br>
<hr>
// Cancel order: The seller cancels the pending order<br>
function revoke(address _nftAddr, uint256 _tokenId) public {<br>
  Order storage _order = nftList[_nftAddr][_tokenId];      // acquire Order<br>
  require(_order.owner == msg.sender, "Not Owner");      // Must be initiated by the holder<br>
  IERC721 _nft = IERC721(_nftAddr);      // declare IERC721 interface contract variable<br>
  require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order")<br>
  _nft.safeTransferFrom(address(this), msg.sender, _tokenId);  // return NFTs back to seller<br>
  delete nftList[_nftAddr][_tokenId];      // delete order<br>

  emit Revoke(msg.sender, _nftAddr, _tokenId);      // release Revoke event<br>
}<br>
<hr>

### Update Price

The seller modifies the NFT order price and releases the Update event. The parameters are the NFT contract address **_nftAddr**, the NFT corresponding **_tokenId**, and the updated order price **_newPrice** (The unit is wei).
<hr>
// Adjust price: The seller adjusts the order price<br>
function update(address _nftAddr, uint256 _tokenId, uint256 _newPrice) public {<br>
  require(_newPrice > 0, "Invalid Price");      // NFT's price is higher than 0<br>
  Order storage _order = nftList[_nftAddr][_tokenId];      // acquire Order<br>
  require(_order.owner == msg.sender, "Not Owner");      // Must be initiated by the holder<br>
  IERC721 _nft = IERC721(_nftAddr);      // declare IERC721 interface contract variables<br>
  require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");      // NFT is in contract<br>
  _order.price = _newPrice;      // adjust NFT's price<br>
  emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);      // Release Update Event<br>
}<br>
<hr>

### Purchase

The buyer pays ETH to purchase the NFT in the order and releases the Purchase event. The parameters are the NFT contract address _nftAddr and the NFT corresponding _tokenId.<br>
After success, ETH will be transferred to the seller, and NFT will be transferred from the NFTSwap contract to the buyer.<br>
<hr>
// Purchase: Buyer purchases NFT, the contract is _nftAddr, tokenId is _tokenId, ETH must be attached when calling the function<br>
function purchase(address _nftAddr, uint256 _tokenId) payable public {<br>
  Order storage _order = nftList[_nftAddr][_tokenId];      // acquire Order<br>
  require(_order.price > 0, "Invalid Price");      // NFT's price should be higher than 0<br>
  require(msg.value >= _order.price, "Increase price");      // purchase price is greater than the listed price<br>
  IERC721 _nft = IERC721(_nftAddr);      // declare IERC721 interface contract variable<br>
  require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");      // NFT is in contract<br>

  _nft.safeTransferFrom(address(this), msg.sender, _tokenId);      // Transferring the NFT to the buyer<br>
  payable(_order.owner).transfer(_order.price);      // Transfer ETH to the seller and refund the excess ETH to the buyer<br>
  payable(msg.sender).transfer(msg.value - _order.price);<br>
  delete nftList[_nftAddr][_tokenId];      // delete order<br>
  emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);      // release Purchase Event<br>
}<br>
<hr>
