pragma solidity ^0.8.0;

contract Oracle {
    uint256 public ethPrice;
    uint256 public usdtPrice;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function setEthPrice(uint256 _ethPrice) public {
        require(msg.sender == owner, "Only the owner can set the ETH price.");
        ethPrice = _ethPrice;
    }

    function setUsdtPrice(uint256 _usdtPrice) public {
        require(msg.sender == owner, "Only the owner can set the USDT price.");
        usdtPrice = _usdtPrice;
    }

    function getEthPrice() public view returns (uint256) {
        return ethPrice;
    }

    function getUsdtPrice() public view returns (uint256) {
        return usdtPrice;
    }
}

