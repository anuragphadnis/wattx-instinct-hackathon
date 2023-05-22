// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract TokenExchange {
    address public admin;
    mapping(uint256 => mapping(uint256 => address)) public buyOrders;
    mapping(uint256 => mapping(uint256 => address)) public sellOrders;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceWattx;
    mapping(address => uint256) public balanceInr;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor() {
        name = "Wattx Token";
        symbol = "WTT";
        decimals = 18;
        totalSupply = 1000000 * (10 ** uint256(decimals));
        admin = msg.sender;
        balanceWattx[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    function add(address to, uint256 value, uint256 inrValue) external returns (bool) {
        require(balanceWattx[to] >= value, "Insufficient balance");
        balanceWattx[to] -= value;
        balanceWattx[to] += value;
        balanceInr[to] -= inrValue;
        return true;
    }

    function deduct(address from, uint256 value, uint256 inrValue) external returns (bool) {
        balanceWattx[from] -= value;
        balanceInr[from] += inrValue;
        return true;
    }

    function mintTokens(address to, uint256 amount) external onlyAdmin {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Invalid amount");

        balanceWattx[to] += amount;
        totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }


    function getTokenBalance(address from) external view returns (uint256) {
        return balanceWattx[from];
    }

    function getInrBalance(address from) external view returns (uint256) {
        return balanceInr[from];
    }

    function depositInt(address to, uint256 amount) external {
        balanceInr[to] += amount;
    }

    function withdrawInr(address from, uint256 amount) external {
        balanceInr[from] -= amount;
    }

    function createBuyOrder(address token, uint256 amount, uint256 price ) external {
        require(amount > 0, "Invalid amount");
        require(price > 0, "Invalid price");
        buyOrders[price][amount] = token;
        if (sellOrders[price][amount] != address(0)) {
            address addr = sellOrders[price][amount];
            this.add(token, amount, price);
            this.deduct(addr, amount, price);
        }
    }

    function createSellOrder(address token, uint256 amount, uint256 price) external {
        require(amount > 0, "Invalid amount");
        require(price > 0, "Invalid price");
        sellOrders[price][amount] = token;
        if (buyOrders[price][amount] != address(0)) {
            address addr = buyOrders[price][amount];
            this.add(addr, amount, price);
            this.deduct(token, amount, price);
        }
    }
}