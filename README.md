# NFT Marketplace

This is a Solidity smart contract for an NFT marketplace that facilitates the trading of ERC721 tokens. It extends the functionality of the ERC721URIStorage contract from the OpenZeppelin library.

## Contract Details

### Structs

- `Token`: Represents an ERC721 token with the following properties:
  - `tokenId`: The unique identifier of the token.
  - `seller`: The address of the token seller.
  - `owner`: The address of the current token owner.
  - `price`: The price of the token.
  - `sold`: Indicates whether the token has been sold.

### Storage Variables

- `_tokenIds`: The total number of tokens created.
- `_itemsSold`: The total number of tokens sold.
- `_listingPrice`: The listing price for creating tokens.
- `_owner`: The address of the marketplace owner.
- `idToToken`: A mapping from token IDs to their corresponding Token struct.

### Events

- `TokenCreated`: Emitted when a new token is created.
- `TokenSold`: Emitted when a token is sold.
- `ResaleCreated`: Emitted when a token is resold.

## Functions

### Constructor

- `constructor()`: Initializes the NFT marketplace contract. It sets the listing price and the contract owner.

### Modifiers

- `onlyOwner()`: Throws an error if the caller is not the marketplace owner.

### External Functions

- `updateListingPrice(uint256 listingPrice)`: Updates the listing price for creating tokens.
- `getListingPrice()`: Retrieves the current listing price.
- `createToken(string memory tokenURI_, uint256 price)`: Creates a new token with the specified token URI and price.
- `buyToken(uint256 tokenId)`: Buys a token with the specified token ID.
- `resellToken(uint256 tokenId, uint256 price)`: Resells a token with the specified token ID and price.
- `fetchAllUnsoldTokens()`: Fetches all unsold tokens.
- `fetchTokensOwnedByMe()`: Fetches tokens owned by the caller.
- `fetchMyListedTokens()`: Fetches tokens listed by the caller.

The contract allows users to create, buy, and resell ERC721 tokens. It also provides functions to fetch unsold tokens, tokens owned by the caller, and tokens listed by the caller.

Note: This contract inherits the ERC721URIStorage contract, which provides additional functions for setting and retrieving the token URI for each token.

To use this contract, you need to import the necessary dependencies from the OpenZeppelin library:
- `ERC721.sol`: Provides the implementation of the ERC721 token standard.
- `ERC721URIStorage.sol`: Extends the ERC721 contract and adds support for setting and retrieving token URIs.