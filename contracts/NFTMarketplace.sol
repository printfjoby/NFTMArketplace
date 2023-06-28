// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    uint256 public _listingPrice ;

    address payable _owner;

    mapping(uint256 => Token) public idToToken;


    event TokenCreated (
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price
    );

    event TokenSold (
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price
    );

     event ResaleCreated (
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price
    );

    constructor() ERC721("NFTMarketPlace", "NFTM") {
      _listingPrice = 0.1 ether;
      _owner = payable(msg.sender);

    }


    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the marketplace owner");
        _;
    }


    function updateListingPrice(uint listingPrice) external onlyOwner {
      _listingPrice = listingPrice;
    }


    function getListingPrice() external view returns (uint256) {
      return _listingPrice;
    }

    function createToken(string memory tokenURI_, uint256 price) external payable returns (uint) {
      require(price > 0, "Price must be at least 1 wei");
      require(msg.value == _listingPrice, "Please send the exact listing price amount");
      
      _tokenIds += 1;

      _mint(msg.sender, _tokenIds);

      _setTokenURI(_tokenIds, tokenURI_);
     
      idToToken[_tokenIds] =  Token(
        _tokenIds,
        payable(msg.sender),
        payable(address(this)),
        price,
        false
      );

      _transfer(msg.sender, address(this), _tokenIds);

      emit TokenCreated(
        _tokenIds,
        msg.sender,
        address(this),
        price
      );

      return _tokenIds;
    }


    function buyToken(
      uint256 tokenId
      ) external payable {
      uint price = idToToken[tokenId].price;
      address seller = idToToken[tokenId].seller;

      require(msg.value == price, "The amount send is not matching with the price");
      idToToken[tokenId].owner = payable(msg.sender);
      idToToken[tokenId].sold = true;
      idToToken[tokenId].seller = payable(address(0));
      _itemsSold += 1;

      _transfer(address(this), msg.sender, tokenId);
      payable(_owner).transfer(_listingPrice);
      payable(seller).transfer(msg.value);

      emit TokenSold(
        _tokenIds,
        msg.sender,
        address(this),
        price
      );

    }


    function resellToken(uint256 tokenId, uint256 price) external payable {
      require(idToToken[tokenId].owner == msg.sender, "Only the token owner is allowed to resell it");
      require(msg.value == _listingPrice, "Please send the exact listing price amount");
      idToToken[tokenId].sold = false;
      idToToken[tokenId].price = price;
      idToToken[tokenId].seller = payable(msg.sender);
      idToToken[tokenId].owner = payable(address(this));
      _itemsSold -= 1;

      _transfer(msg.sender, address(this), tokenId);

      emit ResaleCreated(
        _tokenIds,
        msg.sender,
        address(this),
        price
      );
    }

   


    function fetchAllUnsoldTokens() external view returns (Token[] memory) {
      uint itemCount = _tokenIds;
      uint unsoldItemCount = _tokenIds - _itemsSold;
      uint currentIndex = 0; 

      Token[] memory items = new Token[](unsoldItemCount);
      for (uint i = 1; i <= itemCount; i++) { // i = 1 because the first Token id starts from 1
        if (idToToken[i].owner == address(this)) {
          Token storage currentItem = idToToken[i];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }


    function fetchTokensOwnedByMe() public view returns (Token[] memory) {
      uint totalItemCount = _tokenIds;
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 1; i <= totalItemCount; i++) {
        if (idToToken[i].owner == msg.sender) {
          itemCount += 1;
        }
      }

      Token[] memory items = new Token[](itemCount);
      for (uint i = 1; i <= totalItemCount; i++) {
        if (idToToken[i].owner == msg.sender) {
          Token storage currentItem = idToToken[i];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }


    function fetchMyListedTokens() public view returns (Token[] memory) {
      uint totalItemCount = _tokenIds;
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 1; i <= totalItemCount; i++) {
        if (idToToken[i].seller == msg.sender) {
          itemCount += 1;
        }
      }

      Token[] memory items = new Token[](itemCount);
      for (uint i = 1; i <= totalItemCount; i++) {
        if (idToToken[i].seller == msg.sender) {
          Token storage currentItem = idToToken[i];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }
}