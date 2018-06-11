# CryptoFlowers - Charitable fundraiser
The main goal of the project is to raise funds to to support a charity organization. In an ideal state, the wallet,
as the only receiver of funds should be held by the charity directly.

## Flowers generation
The flowers are randomly generated at the time of contribution, where the amount of a contribution helps to increase a chance for getting a special effect

Interpretation mechanism    [variant (value interval)]
* Flower:                   1 (0-85); 2 (86-170); 3 (171-255);
* Bloom:                    1 (0-51); 2 (52-102); 3 (103-153); 4 (154-204); 5 (205-255)
* Stem:                     1 (0-85); 2 (86-170); 3 (171-255);
* Special:                  None (0-222);1 (223-239); 2 (240-255);
* Color Bloom:              hue variation
* Color Stem:               hue variation
* Color Background:         hue variation

### Token specification (ERC721 - non-transferable)
- Name: CryptoFlowers
- Symbol: FLO
- Total supply: unlimited (uint256 type) based on number of contributions
- Non0transferable

### Flower price
Any contribution above TODO: X ETH will be given one flower. For more flowers a donor can split their contribution into several transactions.

### Token usability
The tokens are a unique badge of contributing to the charity.
The owner can also add a short text to be visualized with the flower as a dedication.
