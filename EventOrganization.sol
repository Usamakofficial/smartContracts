// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;
contract EventContract{
    struct Event{
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }
    
    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextId;

    function createEvent(string memory _name, uint _date, uint _price, uint _ticketCount) public {
        require(_date>block.timestamp, "you can organize event for future date");
        require(_ticketCount>0,"you can organize event if you create more than 0 tickets");

        events[nextId] = Event(msg.sender, _name, _date, _price, _ticketCount,_ticketCount);
        nextId++;
    }

    function buyTickets(uint id, uint quantity) public payable{
        require(events[id].date!=0, "Events does not exist");
        require(events[id].date>block.timestamp, "Event has already occured");
        Event storage _event = events[id];
        require(msg.value==(_event.price*quantity), "insufficient balance");
        require(_event.ticketRemain>=quantity, "Not enough tickets");
        _event.ticketRemain-=quantity;
        tickets[msg.sender][id]=quantity;
    }

    function transfer(uint id, uint quantity, address to) public {
        require(events[id].date!=0, "Event does not exist");
        require(events[id].date>block.timestamp, "Event has already occured");
        require(tickets[msg.sender][id]>=quantity, "You do not have enough tickets");
        tickets[msg.sender][id]-=quantity;
        tickets[to][id]+=quantity;
    }
}
