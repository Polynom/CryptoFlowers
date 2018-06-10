#!/bin/bash

SOLC="solcjs"

SOURCES="../CryptoFlowersCrowdsale.sol ../CryptoFlower.sol ../contracts/token/ERC721/ERC721Token.sol ../contracts/ownership/Ownable.sol ../contracts/token/ERC721/ERC721.sol ../contracts/token/ERC721/ERC721BasicToken.sol ../contracts/token/ERC721/ERC721Basic.sol ../contracts/token/ERC721/ERC721Basic.sol ../contracts/token/ERC721/ERC721Receiver.sol ../contracts/math/SafeMath.sol ../contracts/AddressUtils.sol"

case "$1" in
  "abi")
    echo "Building ABI of contract..."
    cmd="abi"
    ;;
  "bin")
    echo "Building bytecode of contract..."
    cmd="bin"
    ;;
  *)
    echo "Usage: $0 <bin | abi>"
    exit 1
esac

eval $SOLC --$cmd $SOURCES
