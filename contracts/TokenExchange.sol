// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface TokenInterface {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);

  function approve(address spender, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function transferFrom(address from, address to, uint256 amount) external returns (bool);

//   function mint(address to, uint256 amount) external onlyOwner returns (bool);

  function whoami() external view returns (address);

}

contract TokenExchange {
    address public wattxAddress;
    address public inrAddress;
    address public owner;

    struct Order {
        address from;
        uint256 wattxTokens;
        uint256 inrTokens;
    }

    Order[] public buyorders;
    Order[] public sellorders;

    TokenInterface wattx;
    TokenInterface inr;
    constructor(address wattxAddr, address inrAddr) {
        wattxAddress = wattxAddr;
        inrAddress = inrAddr;
        wattx = TokenInterface(wattxAddress);
        inr = TokenInterface(inrAddress);
        owner = msg.sender;
    }

    function getWattxBalance() public view returns (uint256) {
        return wattx.balanceOf(msg.sender);
    }

    function getInrBalance() public view returns (uint256) {
        return inr.balanceOf(msg.sender);
    }

    function createBuyOrder(uint256 wattxTokens, uint256 inrTokens) public {
        buyorders.push(Order({
            from: msg.sender,
            wattxTokens: wattxTokens,
            inrTokens: inrTokens
        }));

        wattx.approve(owner, wattxTokens);
        inr.approve(owner, inrTokens);
    }

    function createSellOrder(uint256 wattxTokens, uint256 inrTokens) public {
        sellorders.push(Order({
            from: msg.sender,
            wattxTokens: wattxTokens,
            inrTokens: inrTokens
        }));
        wattx.approve(owner, wattxTokens);
        inr.approve(owner, inrTokens);
    }

    function executeBuyOrder(uint256 wattxTokens, uint256 inrTokens) public {
        require(msg.sender == owner);
        for (uint i = 0; i < buyorders.length; i++) {
            if (buyorders[i].wattxTokens == wattxTokens && buyorders[i].inrTokens == inrTokens) {
                for (uint j = 0; j < sellorders.length; j++) {
                    if (sellorders[j].inrTokens == inrTokens && sellorders[j].wattxTokens == wattxTokens) {
                        inr.transferFrom(msg.sender, sellorders[j].from, buyorders[i].inrTokens);
                        wattx.transferFrom(sellorders[j].from, msg.sender, buyorders[i].wattxTokens);
                        sellorders[j] = sellorders[sellorders.length - 1];
                        sellorders.pop();
                        buyorders[i] = buyorders[buyorders.length - 1];
                        break;
                    }
                }
            }
        }
    }

    function executeSellOrder(uint256 wattxTokens, uint256 inrTokens) public {
        require(msg.sender == owner);
        for (uint i = 0; i < sellorders.length; i++) {
            if (sellorders[i].wattxTokens == wattxTokens && sellorders[i].inrTokens == inrTokens) {
                for (uint j = 0; j < buyorders.length; j++) {
                    if (buyorders[j].inrTokens == inrTokens && buyorders[j].wattxTokens == wattxTokens) {
                        inr.transferFrom(msg.sender, buyorders[j].from, sellorders[i].inrTokens);
                        wattx.transferFrom(buyorders[j].from, msg.sender, sellorders[i].wattxTokens);
                        buyorders[j] = buyorders[sellorders.length - 1];
                        buyorders.pop();
                        sellorders[i] = sellorders[sellorders.length - 1];
                        break;
                    }
                }
            }
        }
    }
}