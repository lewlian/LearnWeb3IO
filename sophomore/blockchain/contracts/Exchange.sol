// SPDC-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {

  address public cryptoDevTokenAddress;

  constructor(address _CryptoDevtoken) ERC20("CryptoDev LP Token", "CDLP"){
    require(_CryptoDevtoken != address(0), "Token address passed is a null address");
    cryptoDevTokenAddress = _CryptoDevtoken; 
  }

  // this returns the amount of CD tokens that the contract has in its reserve
  function getReserve() public view returns(uint) {
    return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
  }

  // if token reserve is 0 = first addition to liquidity
  // when adding liquidity we don't have to maintain ratio = accept any amount 
  // if not zero == maintain ratio to control impact

  /// @notice Adds liquidity to the exchange 
  /// @param _amount a parameter just like in doxygen (must be followed by parameter name)
  function addLiquidity(uint256 _amount) public payable returns (uint) {
    uint256 liquidity;
    uint256 ethBalance = address(this).balance; // note that this is after adding incoming ETH
    uint256 cryptoDevTokenReserve = getReserve();
    ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);

    // token reserve is empty
    if(cryptoDevTokenReserve == 0) {
      cryptoDevToken.transferFrom(msg.sender, address(this), _amount);
      liquidity = ethBalance;
      _mint(msg.sender, liquidity);
    } else {
      uint256 ethReserve = ethBalance - msg.value;
      // calculate how much CD Tokens user should be allowed to add with the provided eth value 
      uint256 cryptoDevTokenAmount = (msg.value * cryptoDevTokenReserve)/(ethReserve);
      // check to make sure user didn't ask for more than allowed
      require(_amount >= cryptoDevTokenAmount, "Amount of tokens sent is less than the minimum tokens required");

      cryptoDevToken.transferFrom(msg.sender, address(this), cryptoDevTokenAmount);
      liquidity = (totalSupply() * msg.value)/ethReserve;
      _mint(msg.sender, liquidity);
    }
  }

  /// @notice Explain to an end user what this does
  /// @dev Explain to a developer any extra details
  /// @param _amount the amount of LP token that user wants to withdraw
  function removeLiquidity(uint256 _amount) public returns (uint256, uint256) {
    require(_amount > 0, "_amount should be greater than zero");
    uint256 ethReserve = address(this).balance;
    uint256 _totalSupply = totalSupply();

    // Perform calculation of equivalent ETH and CD tokens for withdrawal calculated from constant product formula 
    uint256 ethAmount = (ethReserve * _amount)/ _totalSupply;
    uint256 cryptoDevTokenAmount = (getReserve() * _amount)/ _totalSupply;

    // burn the LP token minted originally from this contract
    _burn(msg.sender, _amount); 
    // Send back the ETH equivalent for withdrawal
    bool success = payable(msg.sender).send(ethAmount);
    require(success, "withdrawal failed");

    // Send back the CryptoDev Token equivalent for withdrawal
    ERC20(cryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);
    return (ethAmount, cryptoDevTokenAmount);
  }

  // Returns the amount ETH/CD tokens that would be returned to the user in the swap 
  function getAmountOfTokens(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
    require(inputReserve > 0 && outputReserve > 0, "invalid reserves");

    uint256 inputAmountWithFee = inputAmount * 99; 

    uint256 numerator = inputAmountWithFee * outputReserve;
    uint256 denominator = (inputReserve * 100) + inputAmountWithFee;
    return numerator/denominator;
  }

  function ethToCryptoDevToken(uint256 _minTokens) public payable {
    uint256 tokenReserve = getReserve();
    uint256 tokensBought = getAmountOfTokens(msg.value, address(this).balance - msg.value, tokenReserve);

    //getAmountOfTokens returns the maximum of what the user is allowed to swap based on the ETH that he is intending to swap
    require(tokensBought >= _minTokens, "insufficient output amount");
    ERC20(cryptoDevTokenAddress).transfer(msg.sender, tokensBought);
  }

  /// @param _minEth is the amount of eth the user will accept
  /// @param _tokensSold is the amount of CD tokens that the user want to sell
  function cryptoDevTokenToEth(uint _tokensSold, uint _minEth) public {
    uint256 tokenReserve = getReserve(); // get the amount of CD tokens in exchange

    // calculated the amount of ETH that should be allowed to swap based on CD tokens
    uint256 ethBought = getAmountOfTokens(_tokensSold, tokenReserve, address(this).balance);
    require(ethBought >= _minEth, "insufficient output amount");

    ERC20(cryptoDevTokenAddress).transferFrom(msg.sender, address(this), _tokensSold);

    payable(msg.sender).transfer(ethBought);
  }
}