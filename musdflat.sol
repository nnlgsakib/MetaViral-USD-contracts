// File: /storage/emulated/0/MTV/Oracle.sol
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


// File: /storage/emulated/0/MTV/MUSD2.sol

// File: /storage/emulated/0/MTV/MUSD.sol
pragma solidity ^0.8.0;

contract MUSD {
    string public constant name = "MetaViral USD";
    string public constant symbol = "MUSD";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public oracleAddress;
    uint256 public constant initialPrice = 1 ether;

    constructor(address _oracleAddress) {
        oracleAddress = _oracleAddress;
        totalSupply = 1000000000 ether;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(uint256 _amount) public {
        require(msg.sender == oracleAddress);
        totalSupply += _amount;
        balanceOf[oracleAddress] += _amount;
        emit Mint(_amount);
    }

    function burn(uint256 _amount) public {
        require(msg.sender == oracleAddress);
        require(balanceOf[oracleAddress] >= _amount);
        totalSupply -= _amount;
        balanceOf[oracleAddress] -= _amount;
        emit Burn(_amount);
    }

    function stabilize() public {
        Oracle oracle = Oracle(oracleAddress);
        uint256 ethPrice = oracle.getEthPrice();
        uint256 usdtPrice = oracle.getUsdtPrice();
        uint256 targetPrice = initialPrice;

        if (ethPrice > 2.5 ether) {
            targetPrice = (ethPrice * 1000) / 2500;
        } else if (usdtPrice < 1 ether) {
            targetPrice = (initialPrice * usdtPrice) / 1 ether;
        }

        if (targetPrice > initialPrice) {
            uint256 mintAmount = (totalSupply * (targetPrice - initialPrice)) / initialPrice;
            mint(mintAmount);
        } else if (targetPrice < initialPrice) {
            uint256 burnAmount = (totalSupply * (initialPrice - targetPrice)) / initialPrice;
            burn(burnAmount);
        }
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Mint(uint256 _amount);
    event Burn(uint256 _amount);
}


