// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
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

    function transfer(address to, uint256 value, uint256 inrValue) external returns (bool) {
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
