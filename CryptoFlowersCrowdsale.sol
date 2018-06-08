pragma solidity ^0.4.21;

import "./CryptoFlower.sol";


contract CryptoFlowerCrowdsale {
    // address of the token
    CryptoFlower public token;

    // price of a flower
    uint256 public price;

    // start and end timestamps when investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // total amount of wei raised
    uint256 public raised;

    bool public finalized;

    // the owner of the contract
    address public owner;

    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }

    event Donation(address indexed purchaser, uint256 value, uint256 totalRaised);
    event Finalized();

    constructor(uint256 _startTime, uint256 _endTime, uint256 _price, address _wallet) public {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_price != 0x0);
        require(_wallet != 0x0);

        token = new CryptoFlower("CryptoFlowers", "FLO");
        startTime = _startTime;
        endTime = _endTime;
        price = _price;
        wallet = _wallet;

        owner = msg.sender;
    }

    function () payable public {
        buyTokens(msg.sender);
    }

    // donation and token purchase method
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(msg.value != 0);

        // check if within buying period
        require(now >= startTime && now <= endTime);

        if (msg.value >= price) {
            uint karma;
            if (msg.value >= 0.1 ether) {
                karma = 16;
            } else if (msg.value >= 0.2 ether) {
                karma = 32;
            } else if (msg.value >= 0.5 ether) {
                karma = 48;
            }

            bytes32 generator = (
                keccak256(block.coinbase)
                ^ keccak256(now)
                ^ keccak256(token.getGen(token.lastId()))
            );

            // mint tokens
            token.mint(beneficiary, generator, karma);
        }

        raised += msg.value; // we don't care about overflows here ;)
        emit Donation(beneficiary, msg.value, raised);

        // forward funds to storage
        wallet.transfer(msg.value);
    }

    function finalize() onlyOwner public {
        require(!finalized);
        require(now > endTime);

        token.transferOwnership(owner);

        finalized = true;
        emit Finalized();
    }
}

