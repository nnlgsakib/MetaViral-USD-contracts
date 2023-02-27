// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MetaViralUSDT {
    string public constant name = "MetaViral USD PEG-Tether";
    string public constant symbol = "USDT";
    uint8 public constant decimals = 18;
    
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    address public owner;
    address public oracle;
    uint256 public exchangeRate;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor() {
        owner = msg.sender;
        oracle = 0x1e418A24A8482913A522C6ED231CBB11FF0e00B9;
        exchangeRate = 1;
        totalSupply = 1000000000 * 10 ** decimals; // Total supply of 1 billion USDT
        balanceOf[msg.sender] = totalSupply; // The contract owner initially has all USDT tokens
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function mint(uint256 amount) public onlyOwner {
        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }
    
    function burn(uint256 amount) public onlyOwner {
        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
    
    function setExchangeRate(uint256 rate) public onlyOwner {
        exchangeRate = rate;
    }
    
    function setOracle(address newOracle) public onlyOwner {
        oracle = newOracle;
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balanceOf[msg.sender]);
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function buy() public payable {
        require(msg.value > 0);
        uint256 amount = msg.value * exchangeRate;
        require(amount <= balanceOf[oracle]);
        balanceOf[oracle] -= amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(oracle, msg.sender, amount);
    }
    
    function sell(uint256 amount) public {
        require(amount > 0);
        uint256 value = amount / exchangeRate;
        require(value <= address(this).balance);
        payable(msg.sender).transfer(value);
        balanceOf[msg.sender] -= amount;
        balanceOf[oracle] += amount;
        emit Transfer(msg.sender, oracle, amount);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

