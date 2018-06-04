pragma solidity ^0.4.24;

import './contracts/token/ERC721/ERC721Token.sol';
import './contracts/ownership/Ownable.sol';

contract CryptoFlower is ERC721Token, Ownable {
    
    constructor(string _name, string _symbol)
    ERC721Token(_name, _symbol)
    public {}

    function lastID() view internal returns (uint256)  {
        return allTokens.length;
    }
    
    function mint(address beneficiary) onlyOwner external returns (bool)  {
        _mint(beneficiary, lastID());
        return true; 
    } 
}
