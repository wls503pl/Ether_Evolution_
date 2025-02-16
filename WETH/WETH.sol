// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    // Event, deposit and withdrawal
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    // Constructor, initialize the name of ERC20
    constructor() ERC20("WETH", "WETH") {}

    // callback function, when the user transfers ETH to the WETH contract, the deposit() function will be triggered
    fallback() external payable
    {
        deposit();
    }

    receive() external payable
    {
        deposit();
    }

    // Deposit function, when the user deposits ETH, mint him an equal amount of WETH
    function deposit() public payable
    {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    // Withdrawal function, the user destroys WETH and withdraws an equal amount of ETH
    function withdraw(uint amount) public
    {
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
}