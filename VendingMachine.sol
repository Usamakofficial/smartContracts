// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

contract vendingMachine{
    address public owner;
    mapping(address => uint) public donutBalances;

    constructor () {
        owner = msg.sender;
        donutBalances[address(this)] = 100;
    }

    function getMachineBalances() public view returns (uint) {
        return donutBalances[address(this)] ;
    }
    function restock(uint amount) public {
        require (msg.sender == owner, "only owner can restock this machine");
        donutBalances[address(this)] += amount ;
    }
    function purchase(uint amount) public payable{
        require(msg.value >= amount*2 ether, "you must pay at least 2 ether per donut");
        require(donutBalances[address(this)] >= amount, "not enough donuts in stock to fulfill you purchase");
        donutBalances[address(this)] -= amount;
        donutBalances[msg.sender] += amount;
    }
}
