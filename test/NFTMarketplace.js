
const { expect } = require("chai");

describe("NFTMarketplace", function () {
  let marketplace;
  let owner;
  let seller;
  let buyer1;
  let buyer2;
  let tokenURI;
  let tokenPrice;
  let tokenId;
  let listingPrice = ethers.parseEther("0.1");

  beforeEach(async function () {
    [owner, seller, buyer1, buyer2] = await ethers.getSigners();

    marketplace = await ethers.deployContract("NFTMarketplace");

    await marketplace.waitForDeployment();

    tokenURI = "https://example.com/token-uri";
    tokenPrice = ethers.parseEther("1.0");

    await marketplace.connect(seller).createToken(tokenURI, tokenPrice, {value: listingPrice});

  });

  it("should create and list an NFT for sale", async function () {
    

    tokenId = await marketplace.tokenIds();

    expect(tokenId).to.equal(1);

    const listing = await marketplace.idToToken(tokenId);

    expect(listing.tokenId).to.equal(tokenId);
    expect(listing.seller).to.equal(seller.address);
    expect(listing.owner).to.equal( await marketplace.getAddress());
    expect(listing.price).to.equal(tokenPrice);
    expect(listing.sold).to.equal(false);
  });

  it("should allow a buyer to purchase an NFT", async function () {

    await marketplace.connect(buyer1).buyToken(tokenId, { value: tokenPrice });

    const listing = await marketplace.idToToken(tokenId);

    expect(listing.owner).to.equal(buyer1.address);
    expect(listing.sold).to.equal(true);
  });


  it("should allow to resell an NFT", async function () {
    const newTokenPrice = ethers.parseEther("2.0");

    tokenId = await marketplace.tokenIds();
    await marketplace.connect(buyer1).buyToken(tokenId, { value: tokenPrice });
    await marketplace.connect(buyer1).resellToken(tokenId, newTokenPrice, { value: listingPrice });

    const listing = await marketplace.idToToken(tokenId);

    expect(listing.seller).to.equal(buyer1.address);
    expect(listing.owner).to.equal(await marketplace.getAddress());
    expect(listing.price).to.equal(newTokenPrice);
    expect(listing.sold).to.equal(false);
  });

  it("should fetch unsold tokens", async function () {
    const unsoldTokens = await marketplace.fetchAllUnsoldTokens();
    tokenId = await marketplace.tokenIds();
    expect(unsoldTokens.length).to.equal(tokenId);
    expect(unsoldTokens[0].tokenId).to.equal(tokenId);
    expect(unsoldTokens[0].seller).to.equal(seller.address);
    expect(unsoldTokens[0].owner).to.equal(await marketplace.getAddress());
    expect(unsoldTokens[0].price).to.equal(tokenPrice);
    expect(unsoldTokens[0].sold).to.equal(false);
    
  });

  it("should fetch tokens purchased by an user", async function () {

    tokenId = await marketplace.tokenIds();
    await marketplace.connect(buyer1).buyToken(tokenId, { value: tokenPrice });
    const userTokens = await marketplace.connect(buyer1).fetchTokensOwnedByMe();

    expect(userTokens.length).to.equal(1);
    expect(userTokens[0].tokenId).to.equal(tokenId);
    expect(userTokens[0].seller).to.equal('0x0000000000000000000000000000000000000000');
    expect(userTokens[0].owner).to.equal(buyer1.address);
    expect(userTokens[0].price).to.equal(tokenPrice);
    expect(userTokens[0].sold).to.equal(true);
  });

  it("should fetch items listed by an user", async function () {

    tokenId = await marketplace.tokenIds();
    const userItems = await marketplace.connect(seller).fetchMyListedTokens();

    expect(userItems.length).to.equal(1);
    expect(userItems[0].tokenId).to.equal(tokenId);
    expect(userItems[0].seller).to.equal(seller.address);
    expect(userItems[0].owner).to.equal(await marketplace.getAddress());
    expect(userItems[0].price).to.equal(tokenPrice);
    expect(userItems[0].sold).to.equal(false);
  });
});
