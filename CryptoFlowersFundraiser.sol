pragma solidity ^0.4.21;

import "./CryptoFlower.sol";

/*
 *  @title CryptoFlowerFundraiser
 *  @dev The contract enables to participate in a charitable fundraiser and be rewarded by a ERC721 collectible item
 *  @dev Transaction sent with Ether above the pricing point will result in issuing a new unique and semi-random token
 */
contract CryptoFlowerFundraiser {
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

    // finalization helper variable
    bool public finalized;

    // the owner of the contract
    address public owner;

    // onlyOwner modifier extracted from OZs' Ownable contract
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // event declaration
    event Donation(address indexed purchaser, uint256 value, uint256 totalRaised);
    event Finalized();

    /*
     *  @dev Constructor of the contract
     *  @param uint256 _startTime - starting time of the fundraiser MUST be set in future
     *  @param uint256 _endTime - time of the end of the fundraiser MUST be larger than _startTime, no funds will be accepted afterwards
     *  @param uint256 _price - minimal contribution to generate a token
     *  @param address _wallet - of the funds destination
     */
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

    /*
     *  @dev fallback function triggering the buyToken procedure
     */
    function () payable public {
        buyTokens(msg.sender);
    }

    /*
     *  @dev donation and token purchase method
     *  @param address beneficiary is the destination of the token ownership
     */
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(msg.value != 0);

        // check if within buying period
        require(now >= startTime && now <= endTime);

        // increase chance to land a special flower if the participation is high enough
        if (msg.value >= price) {
            uint karma;
            if (msg.value >= 0.1 ether) {
                karma = 16;
            } else if (msg.value >= 0.2 ether) {
                karma = 32;
            } else if (msg.value >= 0.5 ether) {
                karma = 48;
            }

            bytes32 generator = keccak256(abi.encodePacked(block.coinbase, now, token.getGen(token.lastID())));

            // mint tokens
            token.mint(beneficiary, generator, karma);
        }

        raised += msg.value; // we don't care about overflows here ;)
        emit Donation(beneficiary, msg.value, raised);

        // forward funds to storage
        wallet.transfer(msg.value);
    }

    /*
     *  @dev finalization function to formally end the fundraiser
     *  @dev only owner can call this
     */
    function finalize() onlyOwner public {
        require(!finalized);
        require(now > endTime);

        token.transferOwnership(owner);

        finalized = true;
        emit Finalized();
    }

    /*
     *  @dev clean up function to call a self-destruct benefiting the owner
     */
    function cleanUp() onlyOwner public {
        selfdestruct(owner);
    }
}