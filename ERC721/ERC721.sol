// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./String.sol";

contract ERC721 is IERC721, IERC721Metadata
{
  // Using the "Strings" Library.
  using Strings for uint256;

  // Token name.
  string public override name;

  // Token symbol.
  string public override symbol;

  // mapping of holder from "tokenId" to owner address.
  mapping(uint => address) private _owners;

  // mapping from owner address to "Open Interest".
  mapping(address => uint) private _balances;

  // mapping from "tokenId" to address approved by owner.
  mapping(uint => address) private _tokenApprovals;

  // mapping from owner address to operator address(volume licensing).
  mapping(address => mapping(address => bool)) private _operatorApprovals;

  // error, Invalid receiver.
  error ERC721InvalidReceiver(address receiver);

  /**
   * constructor, initialize 'name' and 'symbol'.
   **/
  constructor(string memory name_, string memory symbol_)
  {
    name = name_;
    symbol = symbol_;
  }

  // Implement func "supportsInterface" of IERC165 interface.
  function supportsInterface(bytes4 interfaceId) external pure override returns(bool)
  {
    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC165).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId;
  }

  // Implement func "balanceOf" of IERC721, use variable "_balances" to search balance of owner address.
  function balanceOf(address owner) external view override returns(uint)
  {
    require(owner != address(0), "owner = zero address");
    return _balances[owner];
  }

  // Implement func "ownerOf" of IERC721, use variable "_owners" to search owner of "tokenId".
  function ownerOf(uint tokenId) public view override returns(address owner)
  {
    owner = _owners[tokenId];
    require(owner != address(0), "token doesn't exist");
  }

  // Implement func "isApprovedForAll" of IERC721, Use the "_operatorApprovals" variable to query -
  // whether the owner address has authorized the NFTs held by it to the operator address in batches.
  function isApprovedForAll(address owner, address operator)
    external
    view
    override
    returns (bool)
  {
    return _operatorApprovals[owner][operator];
  }

  // Implement func "setApprovalForAll" of IERC721, Authorize all tokens held to the "operator" address.
  // Call the _operatorApprovals function.
  function setApprovalForAll(address operator, bool approved) external override
  {
    _operatorApprovals[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  // Implement func "getApproved" of IERC721,
  // use variable "_tokenApprovals" to search approved address of "tokenId".
  function getApproved(uint tokenId) external view override returns (address)
  {
    require(_owners[tokenId] != address(0), "token doesn't exist");
    return _tokenApprovals[tokenId];
  }

  // Authorization function, approved address "to" to operator tokenId by adjusting "_tokenApprovals",
  // the same time, the "Approval" event is released.
  function _approve(address owner, address to, uint tokenId) private
  {
    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }
  
  /**
   * Implement func "approve" of IERC721, approved tokenId to address "to",
   * this function will call func "_approve".
   * Condition:
   * 1. "to" is not "owner";
   * 2. "msg.sender" is owner or approved address(operator).
   **/
  function approve(address to, uint tokenId) external override
  {
    address owner = _owners[tokenId];
    require(
      msg.sender == owner || _operatorApprovals[owner][msg.sender],
      "not owner nor approved for all"
    );
    _approve(owner, to, tokenId);
  }

  // To search if "spender" address can use "tokenId" (spender should be owner or approved address).
  function _isApprovedOrOwner(
    address owner,
    address spender,
    uint tokenId
    ) private view returns(bool)
  {
        return (spender == owner ||
            _tokenApprovals[tokenId] == spender ||
            _operatorApprovals[owner][spender]);
  }

  /**
   * Transfer function, by adjusting variable "_balances" and "_owner" to transfer tokenId from "from" to "to",
   * release "Transfer" event at the same time.
   * Condition:
   * 1. "tokenId" is owned by address "from";
   * 2. "to" is not 0 address.
   **/
  function _transfer(
    address owner,
    address from,
    address to,
    uint tokenId
  ) private
  {
    require(from == owner, "not owner");
    require(to != address(0), "transfer to the zero address");

    _approve(owner, to, tokenId);
    _balances[from] -= 1;
    _balances[to] += 1;
    _owners[tokenId] = to;

    emit Transfer(from, to, tokenId);
  }

  // Implement func "transferFrom" of IERC721 (Non-secure transfers, not recommended),
  // call funciton "_transfer".
  function transferFrom(address from, address to, uint tokenId) external override
  {
    address owner = ownerOf(tokenId);
    require(
      _isApprovedOrOwner(owner, msg.sender, tokenId),
      "not owner nor approved"
    );
    _transfer(owner, from, to, tokenId);
  }

  /**
   * Secure transfers, safely transfer tokenId from "from" to "to" address.
   * The contract recipient will be checked to see if they understand the ERC721 protocol to prevent tokens from being permanently locked.
   * call function "_transfer" and "_checkOnERC721Received".
   * Condition:
   * 1. "from" is not address 0;
   * 2. "to" is not address 0;
   * 3. if "to" is smart contract, it must support "IERC721Receiver-onERC721Received".
   **/
  function _safeTransfer(
    address owner,
    address from,
    address to,
    uint tokenId,
    bytes memory _data
  ) private
  {
    _transfer(owner, from, to, tokenId);
    _checkOnERC721Received(from, to, tokenId, _data);
  }

  // Implement func "safeTransferFrom" of IERC721, Secure transfers, call function _safeTransfer.
  function safeTransferFrom(
    address from,
    address to,
    uint tokenId,
    bytes memory _data) public override
  {
    address owner = ownerOf(tokenId);
    require(
      _isApprovedOrOwner(owner, msg.sender, tokenId),
      "not owner nor approved"
    );
    
    _safeTransfer(owner, from, to, tokenId, _data);
  }

  // Function "safeTransferFrom" overloading
  function safeTransferFrom(
    address from,
    address to,
    uint tokenId
  ) external override
  {
    safeTransferFrom(from, to, tokenId, "");
  }

  /**
   * Mint function, Cast tokenId by adjusting "_balances" and "_owners" variables and transferred it to address "to", release Transfer event at the same time
   * Condition:
   * 1. "tokenId" does not exist yet
   * 2. "to" is not address 0
   **/
  function _mint(address to, uint tokenId) internal virtual
  {
    require(to != address(0), "mint to zero address");
    require(_owners[tokenId] == address(0), "token already minted");

    _balances[to] += 1;
    _owners[tokenId] = to;

    emit Transfer(address(0), to, tokenId);
  }

  // Destroy function, destroy tokenId by adjusting "_balances" and "_owners" variables and releasing Transfer event
  // Condition: tokenId exists
  function _burn(uint tokenId) internal virtual
  {
    address owner = ownerOf(tokenId);
    require(msg.sender == owner, "not owner of token");

    _approve(owner, address(0), tokenId);

    _balances[owner] -= 1;
    delete _owners[tokenId];

    emit Transfer(owner, address(0), tokenId);
  }

  // _checkOnERC721Received：Used to call IERC721Receiver-onERC721Received when to is a contract,
  // to prevent tokenId from being accidentally transferred into a black hole
  function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private
  {
    if (to.code.length > 0)
    {
      try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval)
      {
        if (retval != IERC721Receiver.onERC721Received.selector)
        {
          revert ERC721InvalidReceiver(to);
        }
      }
      catch (bytes memory reason)
      {
        if (reason.length == 0)
        {
          revert ERC721InvalidReceiver(to);
        }
        else
        {
          // @solidity memory-safe-assembly
          assembly
          {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    }
  }

  // Implement the tokenURI function of IERC721Metadata to query metadata
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
  {
    require(_owners[tokenId] != address(0), "Token Not Exist");
    
    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
  }

  // Calculate the BaseURI of {tokenURI}, where tokenURI is the concatenation of baseURI and tokenId
  // The baseURI of BAYC is ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/
  function _baseURI() internal view virtual returns(string memory)
  {
    return "";
  }
}