// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *@title NFTMarketplace
 *@dev A marketplace contract for trading ERC721 tokens.
*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketplace is ERC721URIStorage {

  struct Token {
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

  uint256 public _tokenIds;
  uint256 public _itemsSold;
  uint256 public _listingPrice;
  address payable _owner;
  mapping(uint256 => Token) public idToToken;

  event TokenCreated(
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price
  );

  event TokenSold(
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price
  );

  event ResaleCreated(
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price
  );

  /**
  * @dev Initializes the NFT marketplace contract.
  */
  constructor() ERC721("NFTMarketPlace", "NFTM") {
    _listingPrice = 0.1 ether;
    _owner = payable(msg.sender);
  }

  /**
  * @dev Throws an error if the caller is not the marketplace owner.
  */
  modifier onlyOwner() {
    require(
      msg.sender == _owner,
      "Caller is not the marketplace owner"
    );
    _;
  }

  /**
  * @dev Updates the listing price for creating tokens.
  * @param listingPrice The new listing price.
  */
  function updateListingPrice(
    uint256 listingPrice
  ) external onlyOwner {
    _listingPrice = listingPrice;
  }

  /**
  * @dev Gets the current listing price.
  * @return The current listing price.
  */
  function getListingPrice() external view returns (
    uint256
  ) {
    return _listingPrice;
  }

  /**
  * @dev Creates a new token with the specified token URI and price.
  * @param tokenURI_ The token URI.
  * @param price The token price.
  * @return The new token's ID.
  */
  function createToken(
    string memory tokenURI_, 
    uint256 price
  ) external
    payable
    returns (uint256){
    require(price > 0, 
      "Price must be at least 1 wei"
    );
    require(
      msg.value == _listingPrice,
      "Please send the exact listing price amount"
    );

    _tokenIds += 1;
    _mint(msg.sender, _tokenIds);
    _setTokenURI(_tokenIds, tokenURI_);

    idToToken[_tokenIds] = Token(
      _tokenIds,
      payable(msg.sender),
      payable(address(this)),
      price,
      false
    );

    _transfer(msg.sender, address(this), _tokenIds);

    emit TokenCreated(_tokenIds, msg.sender, address(this), price);

    return _tokenIds;
  }

  /**
  * @dev Buys a token with the specified token ID.
  * @param tokenId The token ID to buy.
  */
  function buyToken(
    uint256 tokenId
  ) external payable {
    uint256 price = idToToken[tokenId].price;
    address seller = idToToken[tokenId].seller;

    require(
      msg.value == price,
      "The amount sent does not match the price"
    );

    idToToken[tokenId].owner = payable(msg.sender);
    idToToken[tokenId].sold = true;
    idToToken[tokenId].seller = payable(address(0));
    _itemsSold += 1;

    _transfer(address(this), msg.sender, tokenId);
    payable(_owner).transfer(_listingPrice);
    payable(seller).transfer(msg.value);

    emit TokenSold(
      tokenId, 
      msg.sender, 
      address(this), 
      price
    );
  }

  /**
  * @dev Resells a token with the specified token ID and price.
  * @param tokenId The token ID to resell.
  * @param price The new token price.
  */
  function resellToken(
    uint256 tokenId, 
    uint256 price
  ) external payable {
    require(
      idToToken[tokenId].owner == msg.sender,
      "Only the token owner is allowed to resell it"
    );
    require(
      msg.value == _listingPrice,
      "Please send the exact listing price amount"
    );

    idToToken[tokenId].sold = false;
    idToToken[tokenId].price = price;
    idToToken[tokenId].seller = payable(msg.sender);
    idToToken[tokenId].owner = payable(address(this));
    _itemsSold -= 1;

    _transfer(msg.sender, address(this), tokenId);

    emit ResaleCreated(
      tokenId, 
      msg.sender, 
      address(this), 
      price
    );
  }

  /**
  * @dev Fetches all unsold tokens.
  * @return An array of unsold tokens.
  */
  function fetchAllUnsoldTokens() external view returns (
    Token[] memory) {
    uint256 itemCount = _tokenIds;
    uint256 unsoldItemCount = _tokenIds - _itemsSold;
    uint256 currentIndex = 0;

    Token[] memory items = new Token[](unsoldItemCount);
    for (uint256 i = 1; i <= itemCount; i++) {
      if (idToToken[i].owner == address(this)) {
        Token storage currentItem = idToToken[i];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /**
  * @dev Fetches tokens owned by the caller.
  * @return An array of tokens owned by the caller.
  */
  function fetchTokensOwnedByMe() public view returns (
    Token[] memory) {
    uint256 totalItemCount = _tokenIds;
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 1; i <= totalItemCount; i++) {
      if (idToToken[i].owner == msg.sender) {
        itemCount += 1;
      }
    }

    Token[] memory items = new Token[](itemCount);
    for (uint256 i = 1; i <= totalItemCount; i++) {
      if (idToToken[i].owner == msg.sender) {
        Token storage currentItem = idToToken[i];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /**
  * @dev Fetches tokens listed by the caller.
  * @return An array of tokens listed by the caller.
  */
  function fetchMyListedTokens() public view returns (
    Token[] memory) {
    uint256 totalItemCount = _tokenIds;
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 1; i <= totalItemCount; i++) {
      if (idToToken[i].seller == msg.sender) {
        itemCount += 1;
      }
    }

    Token[] memory items = new Token[](itemCount);
    for (uint256 i = 1; i <= totalItemCount; i++) {
      if (idToToken[i].seller == msg.sender) {
        Token storage currentItem = idToToken[i];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

}