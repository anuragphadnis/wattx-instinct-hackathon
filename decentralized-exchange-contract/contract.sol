// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WattxToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceWattx;
    mapping(address => uint256) public balanceInr;
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        name = "Wattx Token";
        symbol = "WTT";
        decimals = 18;
        totalSupply = 1000000 * (10 ** uint256(decimals));
        admin = msg.sender;
        balanceWattx[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function add(address to, uint256 value, uint256 inrValue) external returns (bool) {
        require(balanceWattx[msg.sender] >= value, "Insufficient balance");
        balanceWattx[msg.sender] -= value;
        balanceWattx[to] += value;
        balanceInr[to] -= inrValue;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function mintTokens(address to, uint256 amount) external onlyAdmin {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Invalid amount");

        balanceWattx[to] += amount;
        totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

    function deduct(address from, uint256 value, uint256 inrValue) external returns (bool) {
        balanceWattx[msg.sender] += value;
        balanceWattx[from] -= value;
        balanceInr[from] += inrValue;
        return true;
    }
}


contract TokenExchange {
    WattxToken public wattxToken;
    address public admin;
    mapping(uint256 => mapping(uint256 => address)) public buyOrders;
    mapping(uint256 => mapping(uint256 => address)) public sellOrders;

    function add(address to, uint256 value, uint256 inrValue) external returns (bool) {
        return wattxToken.add(to, value, inrValue);
    }

    function mintTokens(address to, uint256 amount) external onlyAdmin {
        return wattxToken.mintTokens(to, amount);
    }

    function deduct(address from, uint256 value, uint256 inrValue) external returns (bool) {
        return wattxToken.deduct(from, value, inrValue);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createBuyOrder(address token, uint256 amount, uint256 price ) external {
        require(amount > 0, "Invalid amount");
        require(price > 0, "Invalid price");
        buyOrders[price][amount] = token;
        if (sellOrders[price][amount] != address(0)) {
            address addr = sellOrders[price][amount];
            wattxToken.add(token, amount, price);
            wattxToken.deduct(addr, amount, price);
        }
    }

    function createSellOrder(address token, uint256 amount, uint256 price) external {
        require(amount > 0, "Invalid amount");
        require(price > 0, "Invalid price");
        sellOrders[price][amount] = token;
        if (buyOrders[price][amount] != address(0)) {
            address addr = buyOrders[price][amount];
            wattxToken.add(addr, amount, price);
            wattxToken.deduct(token, amount, price);
        }
    }
}