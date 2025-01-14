### ERC721

If a contract does not implement the relevant functions of ERC721, the transferred NFT will go into a black hole and can never be transferred out.
In order to prevent the transfer of funds by mistake, ERC721 implements the "safeTransferFrom()" safe transfer function. The target contract must implement the IERC721Receiver interface to receive ERC721 tokens,
otherwise it will revert. The IERC721Receiver interface only contains one "onERC721Received()" function.

### ERC165 and ERC721 detailed explanation

In order to prevent NFTs from being transferred to a contract that is not capable of operating NFTs, the target must correctly implement the "ERC721TokenReceiver" interface:<br>
<hr>
interface ERC721TokenReceiver
{
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}
<hr>
Expanding to the world of programming languages, whether it is Java's interface or Rust's Trait (of course, in Solidity, what is more similar to trait is library), as long as it is related to interface,<br>
it reveals such a meaning: interface is a collection of certain behaviors(even more so in Solidity, the interface is completely equivalent to a collection of function selectors)<br>
As long as a type implements a certain interface, it means that the type has such a function.<br>
Therefore, as long as a contract type implements the above "IERC721Receiver" interface (more specifically, it implements the onERC721Received function),<br>
the contract type will indicate to the outside world that it has the ability to manage NFTs.

Of course, the logic of operating NFT is implemented in other functions of the contract. When executing safeTransferFrom, the ERC721 standard will check whether the target contract implements the onERC721Received function, 
which is an operation based on the ERC165 concept.

### So what exactly is ERC165?

ERC165 is a technical standard that indicates which interfaces are implemented. As mentioned above, implementing an interface means that the contract has a special ability.<br>
When some contracts interact with other contracts, they expect the target contract to have certain functions.<br>
In this case, the contracts can query each other through the ERC165 standard to check whether the other party has the corresponding capabilities.

Take the "ERC721" contract as an example. When an external party checks whether a contract is ERC721, what should be done? According to this statement,
the checking steps should be to first check whether the contract implements ERC165, and then check other specific interfaces implemented by the contract. At this time,
the specific interface is IERC721. IERC721 is the basic interface of ERC721 (why it is basic, because there are other extensions such as "ERC721Metadata" and "ERC721Enumerable"):<br>
<hr>
//  **⚠⚠⚠ Note: the ERC-165 identifier for this interface is 0x80ac58cd. ⚠⚠⚠**
interface ERC721 /* is ERC165 */ {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
<hr>
0x80ac58cd = bytes4(keccak256(ERC721.Transfer.selector) ^ keccak256(ERC721.Approval.selector) ^ ··· ^keccak256(ERC721.isApprovedForAll.selector)), which is the calculation method specified by ERC165.

Then, similarly, the interface of ERC165 itself can be calculated (its interface has only one function "supportsInterface(bytes4 interfaceID)" external view returns (bool); function, 
and "bytes4(keccak256(supportsInterface.selector))" is used to get 0x01ffc9a7.<br>
In addition, ERC721 also defines some extended interfaces, such as "IERC721Metadata":<br>
<hr>
//  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface ERC721Metadata /* is ERC721 */
{
    function name() external view returns (string _name);
    function symbol() external view returns (string _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string);
}
<hr>
The calculation of 0x5b5e139f is:
IERC721Metadata.name.selector ^ IERC721Metadata.symbol.selector ^ IERC721Metadata.tokenURI.selector

Solamte’s ERC721.sol implements these ERC165 requirements in this way:<br>
<hr>
function supportsInterface(bytes4 interfaceId) public view virtual returns(bool)
{
  return
    interfaceId == 0x01ffc9a7 ||      // ERC165 Interface ID for ERC165
    interfaceId == 0x80ac58cd ||      // ERC165 Interface ID for ERC721
    interfaceId == 0x5b5e139f;        // ERC165 Interface ID for ERC721Metadata
}
<hr>

Yes, it is that simple. When the outside world follows the steps in link1 to check whether this contract implements 165,
it is easy to say that the supportsInterface function must return true when the input parameter is 0x01ffc9a7, and the return value must be false when the input parameter is 0xffffffff.
The above implementation perfectly meets the requirements.<br>
When the outside world wants to check whether this contract is ERC721, it is easy to say that when the input parameter is 0x80ac58cd, it indicates that the outside world wants to do this check, Return true.<br>
When the outside world wants to check whether this contract implements the ERC721Metadata interface of ERC721, the input parameter is 0x5b5e139f, check, return True.<br>
And because the function is virtual, the user of the contract can inherit the contract and continue to implement the ERC721Enumerable interface. After implementing functions such as totalSupply,
reimplement the inherited supportsInterface as:
<hr>
function supportsInterface(bytes4 interfaceId) public view virtual returns(bool)
{
  return
    interfaceId == 0x01ffc9a7 ||      // ERC165 Interface ID for ERC165
    interfaceId == 0x80ac58cd ||      // ERC165 Interface ID for ERC721
    interfaceId == 0x5b5e139f ||      // ERC165 Interface ID for ERC721Metadata
    interfaceId == 0x780e9d63;        // ERC165 Interface ID for ERC721Enumerable
}
<hr>
Elegant, simple, and fully scalable.
