pragma solidity ^0.4.24;

import './contracts/token/ERC721/ERC721Token.sol';
import './contracts/ownership/Ownable.sol';

contract CryptoFlower is ERC721Token, Ownable {


    // Storage of flower generator
    mapping (uint256 => bytes9) genes;

    constructor(string _name, string _symbol)
    ERC721Token(_name, _symbol)
    public {}

    
    
    function mint(address beneficiary, bytes32 generator, uint chance) onlyOwner external returns (bool)  {

        /*  
         *  Interpretation mechanism [variant (value interval)]
         *  Flower:             1 (0-85); 2 (86-170); 3 (171-255); 
         *  Bloom:              1 (0-51); 2 (52-102); 3 (103-153); 4 (154-204); 5 (205-255)
         *  Stem:               1 (0-85); 2 (86-170); 3 (171-255); 
         *  Special:            None (0-222);1 (223-239); 2 (240-255); 
         *  Color Bloom:        16 distinct colors
         *  Color Steem:        16 distinct colors
         *  Color Background:   4 distinct colors
         */  
        
        bytes1[7] memory genome;
        genome[0] = generator[0];
        genome[1] = generator[1];
        genome[2] = generator[2];
        if (uint(generator[3]) + chance >= 255) {
            genome[3] = bytes1(255);
        } else {
            genome[3] = bytes1(uint(generator[3])+chance); 
        }
        genome[4] = generator[4];
        genome[5] = generator[5];
        genome[6] = generator[6];

        genes[lastID() + 1] = bytesToBytes7(genome);
        _mint(beneficiary, lastID() + 1);
        return true; 
    }


    /*
     *  Helper functions
     */ 
     
    function lastID() view public returns (uint256)  {
        return allTokens.length - 1;
    }
    
    function getGen(uint256 tokenID) public view returns(bytes9) {
        return genes[tokenID];
    }
    
    function bytesToBytes7(bytes1[7] b) private pure returns (bytes9) {
        bytes7 out;
        
        for (uint i = 0; i < 7; i++) {
          out |= bytes7(b[i] & 0xFF) >> (i * 8);
        }
        
        return out;
    }
}

 