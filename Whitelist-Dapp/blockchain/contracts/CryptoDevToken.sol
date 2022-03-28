// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {

  uint256 public constant tokenPrice = 0.001 ether;
  //Owning one full token is equivalent to 10**(18) tokens
  uint256 public constant tokensPerNFT= 10*10**18;
  uint256 public constant maxTotalSupply = 10000 *10**18;

  ICryptoDevs CryptoDevNFT;

  mapping(uint256 => bool) public tokenIdsClaimed;

  constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD"){
    CryptoDevNFT = ICryptoDevs(_cryptoDevsContract);
  }

  /**
  * @dev Mints `amount` number of CryptoDevTokens
  * Requirements:
  * - `msg.value` should be equal or greater than the tokenPrice * amount
  */
  function mint(uint256 amount) public payable {
    // the value of ether that should be equal or greater than tokenPrice * amount;
    uint256 _requiredAmount = tokenPrice * amount;
    require(msg.value >= _requiredAmount, "Ether sent is incorrect");
    // total tokens + amount <= 10000, otherwise revert the transaction
    uint256 amountWithDecimals = amount * 10**18;
    require(
        (totalSupply() + amountWithDecimals) <= maxTotalSupply,
        "Exceeds the max total supply available."
    );
    // call the internal function from Openzeppelin's ERC20 contract
    _mint(msg.sender, amountWithDecimals);
  }

  function claim() public {
    address sender = msg.sender;
    uint256 balance = CryptoDevNFT.balanceOf(sender);

    require(balance > 0, "You don't own any Crypto Dev NFTs");

    uint256 amount = 0;

    // Loop through the NFTs that sender has and count, marking them as claimed
    for (uint256 i = 0; i < balance; i++) {
      uint256 tokenId = CryptoDevNFT.tokenOfOwnerByIndex(sender, i);
      if(!tokenIdsClaimed[tokenId]) {
        amount += 1;
        tokenIdsClaimed[tokenId] = true;
      }
    }

    require(amount > 0, "You have already claimed all the tokens");
    _mint(msg.sender, amount * tokensPerNFT);
  }

  // Function to receive Ether
  receive() external payable {}
  // Fallback function is called when msg.data is not empty 
  fallback() external payable{}


}