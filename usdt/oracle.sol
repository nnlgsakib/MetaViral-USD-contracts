// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExchangeRateOracle {
    address public owner;
    uint256 public exchangeRate;
    
    event ExchangeRateUpdated(uint256 newRate);
    
    constructor() {
        owner = msg.sender;
        exchangeRate = 1;
    }
    
    function updateExchangeRate(uint256 newRate) public onlyOwner {
        exchangeRate = newRate;
        emit ExchangeRateUpdated(newRate);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }
}

