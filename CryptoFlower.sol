pragma solidity ^0.4.24;

import './contracts/token/ERC721/ERC721Token.sol';
import './contracts/ownership/Ownable.sol';

contract CryptoFlower is ERC721Token, Ownable {

    // Disallowing transfers
    bool transfersAllowed = false;

    // Storage of flower generator
    mapping (uint256 => bytes7) genes;
    mapping (uint256 => string) dedication;

    event GenGenerated(uint256 tokenID, bytes7 gen);
    event FlowerDedicated(uint256 tokenID, string wording);

    constructor(string _name, string _symbol)
    ERC721Token(_name, _symbol)
    public {}

    function mint(address beneficiary, bytes32 generator, uint karma) onlyOwner external returns (bool)  {

        /*  
         *  Interpretation mechanism [variant (value interval)]
         *  Flower:             1 (0-85); 2 (86-170); 3 (171-255); 
         *  Bloom:              1 (0-51); 2 (52-102); 3 (103-153); 4 (154-204); 5 (205-255)
         *  Stem:               1 (0-85); 2 (86-170); 3 (171-255); 
         *  Special:            None (0-222);1 (223-239); 2 (240-255); 
         *  Color Bloom:        16 distinct colors
         *  Color Stem:        16 distinct colors
         *  Color Background:   4 distinct colors
         */  
        
        bytes1[7] memory genome;
        genome[0] = generator[0];
        genome[1] = generator[1];
        genome[2] = generator[2];
        if (uint(generator[3]) + karma >= 255) {
            genome[3] = bytes1(255);
        } else {
            genome[3] = bytes1(uint(generator[3]) + karma); 
        }
        genome[4] = generator[4];
        genome[5] = generator[5];
        genome[6] = generator[6];

        genes[lastID() + 1] = bytesToBytes7(genome);
        emit GenGenerated(lastID() + 1, genes[lastID() + 1]);
        _mint(beneficiary, lastID() + 1);
        return true; 
    }

    function addDedication(uint256 tokenID, string wording)
    onlyOwnerOf(tokenID)
    public {
        require(bytes(dedication[tokenID]).length == 0);
        dedication[tokenID] = wording;
        emit FlowerDedicated(tokenID, wording);
    }

    /*
     *  Helper functions
     */ 
     
    function lastID() view public returns (uint256)  {
        return allTokens.length - 1;
    }
    
    function getGen(uint256 tokenID) public view returns(bytes7) {
        return genes[tokenID];
    }
    
    function bytesToBytes7(bytes1[7] b) private pure returns (bytes7) {
        bytes7 out;
        
        for (uint i = 0; i < 7; i++) {
          out |= bytes7(b[i] & 0xFF) >> (i * 8);
        }
        
        return out;
    }

    /**
   * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
   * @param _tokenId uint256 ID of the token to validate
   */
    modifier canTransfer(uint256 _tokenId) {
        require(transfersAllowed);
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _;
    }
}

 