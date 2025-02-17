# AMM

An automated market maker (AMM) is an algorithm, or a smart contract that runs on a blockchain, that allows decentralized trading between digital assets.
The introduction of AMMs has created a new way of trading that does not require traditional buyers and sellers to match orders,
but instead creates a liquidity pool through a preset mathematical formula (e.g., a constant product formula) that allows users to trade at any time.<br>
![AMM](https://github.com/wls503pl/Ether_Evolution_/blob/ee/DEX/img/amm.png)<br><br>

Let's take the market of Coke (COLA) and US dollar (USD) as an example to introduce AMM. For convenience, we define the following symbols: x and y represent the total amount of Coke and USD in the market, Δx and Δy represent the change in Coke and USD in a transaction, and L and ΔL represent the total liquidity and change in liquidity.

## Constant Sum Automated Market Maker

CSAMM (Constant Sum Automated Market Maker) is the simplest automatic market maker model, Its transaction constraints are:<br>
***\"k = x + y\"*** <br>
Where k is a constant. That is, the total amount of Coke and dollars in the market before and after the transaction remains unchanged. For example, there are 10 bottles of Coke and 10 dollars in the market, k=20, and the price of Coke is 1 dollar/bottle. I am thirsty and want to take out 2 dollars to exchange for Coke. After the transaction, the total amount of dollars in the market becomes 12. According to the constraint k=20, there are 8 bottles of Coke in the market after the transaction, and the price is 1 dollar/bottle. I got 2 bottles of Coke in the transaction, and the price is 1 dollar/bottle.
<br>
The advantage of CSAMM is that it can ensure that the relative price of tokens remains unchanged, which is very important in stablecoin exchange. Everyone hopes that 1 USDT can always be exchanged for 1 USDC. But its disadvantage is also obvious. Its liquidity is easily exhausted: I only need 10 US dollars to exhaust the liquidity of Coke in the market, and other users who want to drink Coke will not be able to trade.

## Constant Product Automated Market Maker

CPAMM is the most popular automatic market maker model, first adopted by Uniswap. Its constraints during trading are: <br>
***\"k = x * y\"*** <br>

Where k is a constant. That is, the product of the number of Coke and dollars in the market before and after the transaction remains unchanged. In the same example, there are 10 bottles of Coke and 10 dollars in the market liquidity. At this time, k=100, and the price of Coke is 1 dollar/bottle. I am thirsty and want to take out 10 dollars to exchange for Coke. If it is in CSAMM, my transaction will be exchanged for 10 bottles of Coke and exhaust the liquidity of Coke in the market. But in CPAMM, the total amount of dollars in the market after the transaction becomes 20. According to the constraint k=100, there are 5 bottles of Coke in the market after the transaction, and the price is 20/5=4 dollars/bottle. I got 5 bottles of Coke in the transaction, and the price is 10/5=2 dollars/bottle
<br>
The advantage of CPAMM is that it has "unlimited" liquidity: the relative price of tokens will change with buying and selling, and the more scarce the token, the higher the relative price, to avoid liquidity being exhausted. In the example above, the transaction caused the price of Coke to rise from $1/bottle to $4/bottle, thus preventing the market from being sold out.

<hr>

# Decentralized Exchanges

We use smart contracts to write a decentralized exchange \"SimpleSwap\" that supports users to trade a pair of tokens.<br>

\"SimpleSwap\" inherits the **ERC20** token standard to facilitate recording the liquidity provided by liquidity providers. In the **constructor**, we specify a pair of token addresses **token0** and **token1**, and the exchange only supports this pair of tokens, **reserve0** and **reserve1** record the reserve amount of tokens in the contract.
```
contract SimpleSwap is ERC20 {
    //Token contract
    IERC20 public token0;
    IERC20 public token1;

    // Token reserve amount
    uint public reserve0;
    uint public reserve1;

    // Constructor, initialize token address
    constructor(IERC20 _token0, IERC20 _token1) ERC20("SimpleSwap", "SS") {
        token0 = _token0;
        token1 = _token1;
    }
}
```

There are two main types of participants in an exchange: Liquidity Providers (LP) and Traders. Below we implement the functions of these two parts respectively.

## Liquidity provision

Liquidity providers provide liquidity to the market, allowing traders to obtain better quotes and liquidity, and charge a certain fee.<br>
First, we need to implement the function of adding liquidity. When a user adds liquidity to the token pool, the contract needs to record the added LP share.<br>
According to Uniswap V2, the LP share is calculated as follows:
1. When liquidity is first added to a token pool, the LP share ΔL is determined by the square root of the product of the number of tokens added.<br>
   ![deltaL](https://github.com/wls503pl/Ether_Evolution_/blob/ee/DEX/img/deltaL.png)<br>
2. When adding liquidity (not the first time) the LP share is determined by the ratio of the number of added tokens to the pool token reserves (the smaller ratio of the two tokens is taken)<br>
   ![removeLiquidity](https://github.com/wls503pl/Ether_Evolution_/blob/ee/DEX/img/removeLiquidity.png)<br>

Because the **SimpleSwap** contract inherits the ERC20 token standard, after calculating the LP share, the share can be minted to the user in the form of tokens.
The following ***addLiquidity()*** function implements the function of adding liquidity. The main steps are as follows:
1. To transfer the tokens added by the user into the contract, the user needs to authorize the contract in advance.
2. The added liquidity share is calculated according to the formula, and the number of minted LPs is checked.
3. Update the contract's token reserves.
4. Mint LP tokens for liquidity providers.
5. Releases the Mint event.
```
event Mint(address indexed sender, uint amount0, uint amount1);

// Add liquidity, transfer tokens, mint LP
// @param amount0Desired The amount of token0 to be added
// @param amount1Desired The amount of token1 to be added
function addLiquidity(uint amount0Desired, uint amount1Desired) public returns(uint liquidity)
{
  // Transfer the added liquidity to the Swap contract. You need to authorize the Swap contract in advance.
  token0.transferFrom(msg.sender, address(this), amount0Desired);
  token1.transferFrom(msg.sender, address(this), amount1Desired);

  // Calculate the added liquidity
  uint _totalSupply = totalSupply();
  if (_totalSupply == 0)
  {
    // If it is the first time to add liquidity, mint L = sqrt(x * y) units of LP (liquidity provider) tokens
    liquidity = sqrt(amount0Desired * amount1Desired);
  }
  else
  {
    // If it is not the first time to add liquidity,
    // LP will be minted in proportion to the number of tokens added,
    // taking the smaller ratio of the two tokens.
    liquidity = min(amount0Desired * _totalSupply / reserve0, amount1Desired * _totalSupply /reserve1);
  }

  // Check the number of LPs minted
  require(liquidity > 0, 'INSUFFICIENT_LIQUIDITY_MINTED');

  // Update the reserve amount
  reserve0 = token0.balanceOf(address(this));
  reserve1 = token1.balanceOf(address(this));

  // Mint LP tokens for liquidity providers to represent the liquidity they provide
  _mint(msg.sender, liquidity);

  emit Mint(msg.sender, amount0Desired, amount1Desired);
}
```

Next, we need to implement the function of removing liquidity. When a user removes liquidity ΔL from the pool, the contract will destroy the LP share tokens and return the tokens to the user in proportion.<br>
The calculation formula for returning tokens is as follows:
![]()

The following ***removeLiquidity()*** function implements the function of removing liquidity.<br>
The main steps are as follows:
1. Get the token balance in the contract.
2. The number of tokens to be transferred is calculated based on the LP ratio.
3. Check the number of tokens.
4. Destroy LP shares.
5. Transfer the corresponding tokens to the user.
6. Update reserve quantities.
7. Releases the **\"Burn\"** event.

```
// Remove liquidity, destroy LP, transfer tokens
// Transfer out amount = (liquidity / totalSupply_LP) * reserve
// @param liquidity The amount of liquidity removed
function removeLiquidity(uint liquidity) external returns (uint amount0, uint amount1)
{
  // Get the balance
  uint balance0 = token0.balanceOf(address(this));
  uint balance1 = token1.balanceOf(address(this));

  // Calculate the number of tokens to be transferred according to the LP ratio
  uint _totalSupply = totalSupply();
  amount0 = liquidity * balance0 / _totalSupply;
  amount1 = liquidity * balance1 / _totalSupply;

  // Check the number of tokens
  require(amount0 > 0 && amount1 > 0, 'INSUFFICIENT_LIQUIDITY_BURNED');

  //Destroy LP
  _burn(msg.sender, liquidity);

  // Transfer out tokens
  token0.transfer(msg.sender, amount0);
  token1.transfer(msg.sender, amount1);

  // Update the reserve amount
  reserve0 = token0.balanceOf(address(this));
  reserve1 = token1.balanceOf(address(this));

  emit Burn(msg.sender, amount0, amount1);
}
```

At this point, the functions related to liquidity providers in the contract are completed. The next step is the transaction part.

## Exchange

In the Swap contract, users can use one token to trade for another. So how many units of token1 can I exchange with Δx units of token0? Let's do a simple deduction.
According to the constant product formula, before the transaction:
***\"k = x ∗ y\"*** <br>
After the transaction, we have:
***\"k = (x+Δx) ∗ (y+Δy)\"*** <br>
The k value remains unchanged before and after the transaction. Combining the above equations, we can get:
***\"Δy = −(Δx ∗ y) / (x + Δx)\"***

Therefore, the amount of tokens that can be exchanged, Δy, is determined by Δx, x, and y. Note that Δx and Δy have opposite signs, because transfers in increase the token reserve, while transfers out decrease it.
The following ***getAmountOut()*** implementation calculates the amount of an asset to be exchanged for another token given the amount of an asset and the reserves of a token pair.
```
// Given the amount of an asset and the reserves of a token pair, calculate the amount of another token to exchange
function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure returns (uint amountOut) {
    require(amountIn > 0, 'INSUFFICIENT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
    amountOut = amountIn * reserveOut / (reserveIn + amountIn);
}
```

With this core formula, we can start implementing the trading function. The following swap() function implements the function of trading tokens. The main steps are as follows:
1. When calling the function, the user specifies the number of tokens to be exchanged, the exchange token address, and the minimum amount of another token to be exchanged.
2. Determine whether token0 is exchanged for token1, or token1 is exchanged for token0.
3. Using the above formula, calculate the number of tokens exchanged.
4. Determine whether the exchanged tokens have reached the minimum number specified by the user, which is similar to the slippage of the transaction.
5. Transfer the user's tokens into the contract.
6. Transfer the exchanged tokens from the contract to the user.
7. Update the contract's token reserves.
8. Releases the Swap event.
```
// Swap token
// @param amountIn The amount of tokens to exchange
// @param tokenIn The token contract address used for exchange
// @param amountOutMin The minimum amount of another token to be exchanged
function swap(uint amountIn, IERC20 tokenIn, uint amountOutMin) external returns (uint amountOut, IERC20 tokenOut)
{
    require(amountIn > 0, "INSUFFICIENT_OUTPUT_AMOUNT");
    require(tokenIn == token0 || tokenIn == token1, 'INVALID_TOKEN');

    uint balance0 = token0.balanceOf(address(this));
    uint balance1 = token1.balanceOf(address(this));

    if (tokenIn == token0)
    {
        // If tokenIn is token0, exchange it for token1
        tokenOut = token1;

        // Calculate the number of token1 that can be exchanged
        amountOut = getAmountOut(amountIn, balance0, balance1);
        require(amountOut > amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');

        // Swap
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenOut.transfer(msg.sender, amountOut);
    }
    else
    {
        // If tokenIn is token1, exchange it for token0
        tokenOut = token0;

        // Calculate the number of token1 that can be exchanged
        amountOut = getAmountOut(amountIn, balance1, balance0);
        require(amountOut > amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');

        // Swap
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenOut.transfer(msg.sender, amountOut);
    }

    // Update the reserve amount
    reserve0 = token0.balanceOf(address(this));
    reserve1 = token1.balanceOf(address(this));

    emit Swap(msg.sender, amountIn, address(tokenIn), amountOut, address(tokenOut));
}
```

<hr>

# Remix Demo

- **Step1**: Deploy two ERC20 token contracts (token0 and token1) and record their contract addresses.
  ![]()<br><br>

- **Step2**: Deploy the SimpleSwap contract and fill in the token address above.
  ![]()<br><br>

- **Step3**: Call the ***approve()*** function of two ERC20 tokens to authorize 1000 units of tokens to the SimpleSwap contract respectively.
  ![]()<br><br>

- **Step4**: Call the ***addLiquidity()*** function of the \"SimpleSwap\" contract to add liquidity to the exchange, adding 100 units to token0 and token1 respectively.
  ![]()<br><br>

- **Step5**: Call the ***balanceOf()*** function of the \"SimpleSwap\" contract to check the user's LP share, which should be 100. ($\sqrt{100*100}=100$).
  ![]()<br><br>

- **Step6**: Call the ***swap()*** function of the \"SimpleSwap\" contract to trade tokens, using 100 units of token0.
  ![]()<br><br>

- **Step7**: Call the **reserve0** and **reserve1** functions of the \"SimpleSwap\" contract to view the token reserves in the contract, which should be **200** and **50**. In the previous step, we used 100 units of token0 to exchange 50 units of token 1 ($\frac{100*100}{100+100}=50$).
  ![]()<br><br>

