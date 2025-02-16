# concept

A Dutch auction is a type of auction where the price starts high and then gradually decreases until a buyer is willing to accept the current price.<br>
Here are some key points about a Dutch auction:<br>
1. Auction process<br>
- The auctioneer sets a high starting price.<br>
- The price is gradually reduced at predetermined intervals until a buyer is willing to accept the current price.<br>
- The first buyer to indicate a willingness to buy wins the auction and purchases the item at that price.

2. Application Scenario<br>
- Dutch auctions are often used for auctions of perishable goods (such as flowers and fish) or for auctions that need to be completed quickly.<br>
- This auction format is also used in some financial products and initial coin offerings (ICOs).

3. Advantage<br>
- Fast: Auctions are usually completed in a short time because prices are constantly falling.<br>
- Price discovery: Buyers can decide when to bid based on their valuation and needs.

4. Differences from traditional auctions<br>
- Traditional auctions (such as English auctions) usually start with a low price and gradually increase the price until there are no higher bids.<br>

Dutch auctions provide an efficient price discovery mechanism, particularly suitable for market environments that require rapid decision-making.
<hr>

## Deploy Contract

First, we should set Auction Start Time, we use Unix time as input.<br>
From this link: [Unix Time Switch](https://tool.chinaz.com/tools/unixtime.aspx)
<br>
We set UTCTime，2025-1-15 15:55:00 as Auction start time, and change it to Unix Time.
![UTC Time to Unix Time](https://github.com/wls503pl/Ether_Evolution_/blob/ee/DutchAuction/img/unixTime.png)
<br>
<hr>
Set "Unix Time" as timestamp, here is 1736927700, and deploy contract.
<br>
![Deploy Contract](https://github.com/wls503pl/Ether_Evolution_/blob/ee/DutchAuction/img/setAuctionStartTime.png)
<br>
<hr>

uint256 public constant COLLECTION_SIZE = 10000;  // NFT total quantity <br>
uint256 public constant AUCTION_START_PRICE = 1 ether;  // Starting Price <br>
uint256 public constant AUCTION_END_PRICE = 0.1 ether;  // End price (lowest price) <br>
uint256 public constant AUCTION_TIME = 10 minutes;  // The auction time is set to 10 minutes for testing purposes <br>
uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes;  // How long does it take for the price to decay? <br>

// Each price decay step
uint256 public constant AUCTION_DROP_PER_STEP = (AUCTION_START_PRICE - AUCTION_END_PRICE) / (AUCTION_TIME / AUCTION_DROP_INTERVAL); <br>

We could see We can see that every 1 minute, the auction price decreases by AUCTION_DROP_PER_STEP.
![Auction Price Changes](https://github.com/wls503pl/Ether_Evolution_/blob/ee/DutchAuction/img/AuctionPriceChanges.png)<br>
