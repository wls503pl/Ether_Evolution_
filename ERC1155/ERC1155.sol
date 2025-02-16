// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./IERC1155MetadataURI.sol";
import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/String.sol";
import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/IERC165.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev ERC1155 multi-token standard
 * See https://eips.ethereum.org/EIPS/eip-1155
 */
contract ERC1155 is IERC165, IERC1155, IERC1155MetadataURI
{
    //Use the Address library and use isContract to determine whether the address is a contract
    using Address for address;

    // Using the Strings library
    using Strings for uint256;

    // token name
    string public name;

    // token symbol
    string public symbol;

    // Mapping of token type id to account account to balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Batch authorization mapping from initiator address address to authorized address operator to whether to authorize bool
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // constructor, initialize `name`, `symbol` and `URI`
    constructor(string memory name_, string memory symbol_)
    {
        name = name_;
        symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool)
    {
        return 
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            interfaceId == type(IERC165).interfaceId;        
    }

    /**
     * @dev Position query implements IERC1155's balanceOf and returns the id type token holdings of the account address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256)
    {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev Batch position query
     * Requirements:
     * - The length of `accounts` and `ids` arrays are equal.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
    public view virtual override returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");
        uint256[] memory batchBalances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; ++i)
        {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }
        return batchBalances;
    }

    /**
     * @dev Batch authorization, the caller authorizes the operator to use all its tokens
     * Release {ApprovalForAll} event
     * Condition: msg.sender != operator
     */
    function setApprovalForAll(address operator, bool approved) public virtual override
    {
        require(msg.sender != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev Query batch authorization.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev secure transfer, transfer the token of type `id` of `amount` unit from `from` to `to`
     * Release {TransferSingle} event.
     * Requirements:
     * - to cannot be a zero address.
     * - from has sufficient holdings and the caller has authorization
     * - If to is a smart contract, it must support IERC1155Receiver-onERC1155Received.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override
    {
        address operator = msg.sender;
        // The caller is the holder or authorized
        require(
            from == operator || isApprovedForAll(from, operator),
            "ERC1155: caller is not token owner nor approved"
        );

        require(to != address(0), "ERC1155: transfer to the zero address");

        // The from address has sufficient holdings
        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");

        // Update Holdings
        unchecked
        {
            _balances[id][from] = fromBalance - amount;
        }

        _balances[id][to] += amount;

        // release event
        emit TransferSingle(operator, from, to, id, amount);

        // Security check
        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev Batch secure transfer, transfer the tokens of the `ids` array type in the `amounts` array unit from `from` to `to`
     * Release {TransferBatch} event.
     * Requirements:
     * - to cannot be a 0 address.
     * - from has sufficient holdings and the caller has authorization
     * - If to is a smart contract, it must support IERC1155Receiver-onERC1155BatchReceived.
     * - ids and amounts array lengths are equal
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override
    {
        address operator = msg.sender;
        // The caller is the holder or authorized
        require(
            from == operator || isApprovedForAll(from, operator),
            "ERC1155: caller is not token owner nor approved"
        );
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        // The caller is the holder or authorized
        for (uint256 i = 0; i < ids.length; ++i)
        {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");

            unchecked
            {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);
        // Security Check
        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data); 
    }

    /**
     * @dev casting
     * Releases the {TransferSingle} event.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual 
    {
        require(to != address(0), "ERC1155: mint to the zero address");
        address operator = msg.sender;
        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);
        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev batch casting
     * Release {TransferBatch} event.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual
    {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = msg.sender;
        for (uint256 i = 0; i < ids.length; i++)
        {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);
        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev destroy
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount) internal virtual
    {
        require(from != address(0), "ERC1155: burn from the zero address");
        address operator = msg.sender;

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked
        {
            _balances[id][from] = fromBalance - amount;
        }
        emit TransferSingle(operator, from, address(0), id, amount);
    }
    
    /**
     * @dev batch destruction
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts) internal virtual
    {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        address operator = msg.sender;

        for (uint256 i = 0; i < ids.length; i++)
        {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");

            unchecked
            {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    // @dev ERC1155 security transfer check
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract())
        {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns(bytes4 response)
            {
                if (response != IERC1155Receiver.onERC1155Received.selector)
                {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            }
            catch Error(string memory reason)
            {
                revert(reason);
            }
            catch
            {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    // @dev ERC1155 batch security transfer check
    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response)
            {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector)
                {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            }
            catch Error(string memory reason)
            {
                revert(reason);
            }
            catch
            {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    /**
     * @dev returns the URI of the ERC1155 id type token, stores metadata, similar to the ERC721 tokenURI.
     */
    function uri(uint256 id) public view virtual override returns (string memory)
    {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, id.toString())) : "";
    }

    /**
     * Calculate the BaseURI of {uri}. uri is the concatenation of baseURI and tokenId. It needs to be rewritten.
     */
    function _baseURI() internal view virtual returns (string memory)
    {
        return "";
    }
}
