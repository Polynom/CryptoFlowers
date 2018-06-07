pragma solidity ^0.4.24;

import "./contracts/ownership/Ownable.sol";
import "./CryptoFlower.sol";

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
    using SafeMath for uint256;

    // The token being sold
    CryptoFlower public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // amount of raised money in wei
    uint256 public weiRaised;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    constructor(uint256 _startTime, uint256 _endTime, address  _wallet) public {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_wallet != 0x0);
        

        token = createTokenContract();
        startTime = _startTime;
        endTime = _endTime;
        wallet = _wallet;
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    function createTokenContract() internal returns (CryptoFlower) {
        return new CryptoFlower("CryptoFlowers","FLO");
    }
    // fallback function can be used to buy tokens
    function () payable public {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable;


    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        return now > endTime;
    }


}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasEnded());

        finalization();
        emit Finalized();

        isFinalized = true;
    }

    /**
     * @dev Can be overridden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal {
        token.transferOwnership(owner); 
    }
    
}

/**
 * @title CryptoFlowers fundraiser
 */
contract Garden is FinalizableCrowdsale {

    /*
     * TODO: finish comments ... - the public donation address
     * @dev please check for due diligence:
     * @notice Link to English site: TODO: fill
     * @notice Link to Etherscan: https://etherscan.io/address/0x3c2FFF4671fA239D5e167e5356058DF11a799aCe
     */

    // Utility variables
    address public owner;
    uint256 public price; 
    bool fundraising;

    // Fundraising finalization events
    event finishFundraiser(uint raised);

    constructor(uint256 _startTime, uint256 _endTime, address _wallet, uint256 _price)
    FinalizableCrowdsale()
    Crowdsale(_startTime, _endTime, _wallet)
    public
    {
        owner = msg.sender;
        fundraising = true;
        price = _price; 
    }

    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint chance;
        if (msg.value >= 100000000000000000) {
            chance = 16;
        } else if (msg.value >= 200000000000000000) {
            chance = 32
        } else if (msg.value >= 500000000000000000) {
            chance = 48
        }

        uint256 flowersCount = (msg.value/price);
        bytes32 generator = keccak256(now + uint(token.getGen(token.lastID())));

        // Mint tokens
        for (uint i = 0; i < flowersCount; i++) {
            token.mint(beneficiary, generator, msg.value);
        }

        // update state
        weiRaised = weiRaised.add(msg.value);
    }

    function finalization() internal {
        // Check the "prepareFinalization" function was called
        require(true);

        // TODO: do whatever
        
        super.finalization();
    }

}