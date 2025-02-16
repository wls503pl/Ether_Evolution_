## To verify the functionality implemented by the exchange, we perform the following steps

### Step1: Deploy NFT contract

Refer to **ERC721**, and deploy **RCApe** contract, set token name "Rich" and symbol "RC".<br>
Mint the first NFT to yourself(Minting it to yourself is for the purpose of listing the NFT, modifying the price, and other operations later).<br>

function ***mint(address to, uint tokenId)*** has 2 parameters:<br>
- to:
Mint the NFT to a specified address, which is usually your own wallet address.<br>
- tokenId:
The RCApe contract defines a total of 10,000 NFTs. As shown in the figure below, the first and second NFTs are minted, and the tokenIds are 0 and 1 respectively.
![Mint token 0](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/NFT_mint.png)
![Mint token 1](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/NFT_mint1.png)

In the RCApe contract, use function *ownerOf* to confirm that you have obtained the NFT with tokenId 0 and 1.
![Owner of token0](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/ownerOfToken0.png)
![Owner of token1](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/ownerOfToken1.png)

### Step2: Deploy NFTSwap cntract

### Step3: Authorizethe NFT to be listed to the NFTSwap contract

In RCApe contract, call function *approve()*, authorize your owned token0 to NFTSwap contract.<br>

function ***approve(address to, uint tokenId)*** has 2 parameters:<br>
- to:
Authorize tokenId to address "to", here it authorized token to NFTSwap contract address.<br>
- tokenId:
It is NFT's id, for token0, it is "0".
![ApproveToken0](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/token0ApproveToNFTSwapContract.png)

(note: NFTSwap address here is: "0x7ef2e0 ... cb47")

According to the above method, the NFT with tokenId 1 is also authorized to the NFTSwap contract address.
![ApproveToken1](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/token1ApproveToNFTSwapContract.png)

### Step4: Listing NFT

Call function *list()* of NFTSwap contract, listing your owned token0 NFT on NFTSwap at price 111 Wei.<br>

function ***list(address _nftAddr, uint256 _tokenId, uint256 _price)*** has 3 parameters:<br>
- _nftAddr:
Address of NFT contract, here is RCApe contract's address.
- _tokenId:
_tokenId is NFT's id, here it is the minted token0's id "0".<br>
- _price:
_price is NFT's price, here it is 111 Wei.
![List Token0](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/listNFTatPrice111.png)

### Step5: View Listed NFTs

Call contract NFTSwap's function *nftList()* to view listed NFT.<br>

- nftList:
It is a mapping of struct "Order", nftList[_nftAddr][_tokenId] returns a NFT order after input "_nftAddr" and "_tokenId".
![View Listed NFT](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/listeNFTPriceUpdated.png)

### Step6: Update NFT's Price

Call NFTSwap contract's functin *update()*, update NFT token0's price to 77 Wei.<br>

function ***update(address _nftAddr, uint256 _tokenId, uint256 _newPrice)*** has 3 parameters:<br>
- _nftAddr:
_nftAddr is address of NFT contract, here it is address of RCApe contract.
- _tokenId:
NFT's id, here it is minted token's id "0".
- _newPrice:
_newPrice is NFT's new price, here it is 66 Wei.
![Update NFT Price](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/listeNFTPriceUpdated.png)

### Step7: Delisting NFTs

Call function *revoke()* of NFTSwap to delist NFT.
function ***revoke(address _nftAddr, uint256 _tokenId)*** has 2 parameters:<br>
- _nftAddr:
_nftAddr is address of NFT contract, here it is address of RCApe contract.
- _tokenId:
_tokenId is NFT's id, here it is token ID "0"

We could see that after function ***revoke()*** run, the Order object's owner and price are all cleared.
![Delist NFT](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/revokeTokenId0.png)


### Step8: Buy NFT

Change the account(Wallet to address "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"), call function ***purchase()*** of NFTSwap contract to buy NFT.<br>
When buying NFT, we need to input NFT contract's address, tokenId and ETH you need to pay. As we delisted NFT token0, now we update NFT token1's price to 126 Wei.<br>

function ***purchase(address _nftAddr, uint256 _tokenId, uint256 _wei)*** has 3 parameters:<br>
- _nftAddr:
_nftAddr is address of NFT contract, here it is address of RCApe contract.
- _tokenId:
_tokenId is NFT token's id, here it is 1.
- _wei:
_wei is amount of ETH you need to pay.

Here we pay 128 Wei(Over listed price).

![Purchase NFT](https://github.com/wls503pl/Ether_Evolution_/blob/ee/NFTExchanges/img/pay128WeiToPurchaseToken1.png)

### Step9: Verify NFT holder changes

Just call function *ownerOf()* of RCApe's contract, we could see NFT token1's holder has been changed to "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2".

The last thing to say is:<br>

Although **OpenSea** has made great contributions to the development of NFT, its shortcomings are also very obvious: high handling fees, no token issuance to reward users,
and trading mechanisms that are easily phished and lead to user asset loss. Currently, new NFT trading platforms such as *Looksrare* and ***dydx*** are challenging **OpenSea**'s position,
and **Uniswap** is also researching new NFT exchanges. I believe that in the near future, we will use better NFT exchanges.
