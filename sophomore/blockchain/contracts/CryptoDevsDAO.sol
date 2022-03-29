// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IFakeNFTMarketplace {
  function getPrice() external view returns (uint256);
  function available(uint256 _tokenId) external view returns (bool);
  function purchase(uint256 _tokenId) external payable;
}

interface ICryptoDevsNFT {
  function balanceOf(address owner) external view returns (uint256);
  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

contract CryptoDevsDAO is Ownable {
  
  struct Proposal {
    uint256 nftTokenId;
    uint256 deadline;
    uint256 yayVotes;
    uint256 nayVotes;
    bool executed;
    mapping(uint256 => bool) voters;
  }

  enum Vote{
    YAY,
    NAY
  }

  mapping(uint256 => Proposal) public proposals;
  uint256 public numProposals;

  IFakeNFTMarketplace nftMarketplace;
  ICryptoDevsNFT cryptoDevsNFT;

  constructor(address _nftMarketplace, address _cryptoDevsNFT) payable {
    nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
    cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
  }

  // Ensure that only NFT holders can perform certain actions 
  modifier nftHolderOnly() {
    require(cryptoDevsNFT.balanceOf(msg.sender) > 0 , "Not a DAO member");
    _;
  }

  // Ensure that proposal to be voted on should not have expired
  modifier activeProposalOnly(uint256 proposalIndex){
    require(proposals[proposalIndex].deadline > block.timestamp, "Deadline exceeded");
    _;
  }

  // Ensure that proposal to be executed should have already reached deadline 
  modifier inactiveProposalOnly(uint256 proposalIndex){
    require(proposals[proposalIndex].deadline <= block.timestamp,"Deadline not exceeded");
    require(proposals[proposalIndex].executed == false, "Proposal already executed");
    _;
  }

  // Allow NFT holders to create proposal
  function createProposal(uint256 _nftTokenId) external nftHolderOnly returns (uint256) {
    require(nftMarketplace.available(_nftTokenId), "NFT not available");
    Proposal storage proposal = proposals[numProposals];
    proposal.nftTokenId = _nftTokenId;
    proposal.deadline = block.timestamp + 5 minutes;

    numProposals++;

    return numProposals - 1; 
  }

  function voteOnProposal(uint256 proposalIndex, Vote vote) external nftHolderOnly activeProposalOnly(proposalIndex){
    Proposal storage proposal = proposals[proposalIndex];

    uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
    uint256 numVotes = 0;

    for (uint256 i = 0; i < voterNFTBalance; i++){
      uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
      if(proposal.voters[tokenId] == false) {
        numVotes++;
        proposal.voters[tokenId] = true;
      }
    }

    require(numVotes > 0, "Already voted");

    if (vote == Vote.YAY) {
      proposal.yayVotes += numVotes;
    } else {
      proposal.nayVotes += numVotes;
    }
  }

  function executeProposal(uint256 proposalIndex) external nftHolderOnly inactiveProposalOnly(proposalIndex){
    Proposal storage proposal = proposals[proposalIndex];

    if (proposal.yayVotes > proposal.nayVotes){
      uint256 nftPrice = nftMarketplace.getPrice();
      require(address(this).balance >= nftPrice, "Not enough funds to purchase");
      // This is how you have arguments along with sending eth
      nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
    }
    proposal.executed = true;
  }

  function withdrawEther() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  receive() external payable {}

  fallback() external payable {}
}