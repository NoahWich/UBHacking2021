// SPDX-License-Identifier: MIT

pragma solidity 0.8.9; 


// TODO We need to find a data to store the event structure.
// as well as change buy tickets and any functions that require ticket info related direclty to an event
// TODO Figure out mapping for address to events, 

contract TheEventFunctions {

struct evnt {
    string name;
    uint256 ticketSupply;
    uint256 remainSupply;
    uint256 ticketPrice;
}

address eventOwner;
uint256 creatorCost = 500000;

// TEST CASES DELETE LATER!!
uint256 price = 50;


// Address mapping for membership, creators and how many tickets a user holds
mapping(address => uint256) creator;
mapping(address => uint256) membership;
mapping(address => uint256[10]) numTickets;

// uint256 array for Event Creators, which will hold all details of their event
mapping(address => evnt) eventDetails;
address[] eventAddr;


// Constructor function to set up the contract upon deployment 
constructor() {
    // address owner = msg.sender;
    creator[msg.sender] = 1;
    membership[msg.sender] = 1;
    eventAddr.push(msg.sender);
}

function registerCreator() public payable {
    require(msg.value == creatorCost);               //Cost in EVNT for Creator to be welcomed to the network 500k EVNT
    address verifiedCreator = msg.sender;
    creator[verifiedCreator] = 1;               // Sets address who calls the creator as a creator for the Application
    membership[verifiedCreator] = 1;            // Also allows the creator a membership to the Application
}

function registerUser() public {
    address eventUser = msg.sender;
    membership[eventUser] = 1;
}

modifier VeriCreator {
    require(creator[msg.sender] == 1, "You must have creator permissions");
    _;
}

modifier regUser {
    require(membership[msg.sender] == 1, "You must be a registered user");
    _;
}

// TODO Update to a required paid amount
function publishEvent(string memory _name, uint256 _supply, uint256 _price) public VeriCreator payable {
    address creatorAddr = msg.sender;
    eventAddr.push(creatorAddr);
    eventDetails[creatorAddr].name = _name;
    eventDetails[creatorAddr].ticketSupply = _supply;
    eventDetails[creatorAddr].ticketPrice = _price;
    eventDetails[creatorAddr].remainSupply = _supply;
} 

// TODO FIX FOR INDIVIDUAL EVENTS
function myTickets(uint256 eventID) public view returns (uint256 Tix) {
    return numTickets[msg.sender][eventID];
} 

function eventName(uint256 eventID) public view returns(string memory EventName) {
    return eventDetails[eventAddr[eventID]].name;
}

function tixRemain(uint256 eventID) public view returns(uint256 Supply) {
    return eventDetails[eventAddr[eventID]].remainSupply;
}

function tixPrice(uint256 eventID) public view returns(uint256 Price) {
    return eventDetails[eventAddr[eventID]].ticketPrice;
}

function buyTickets(uint256 eventID, uint256 _numTix) public regUser payable returns (uint256 X) {
    require(msg.value == _numTix * price, "Only pay the proper amount for tickets!");
    numTickets[msg.sender][eventID] = numTickets[msg.sender][eventID] + _numTix;
    eventDetails[eventAddr[eventID]].remainSupply -= _numTix;
    X = numTickets[msg.sender][eventID];
    return X;
}

function redeemTickets(address userAddress, uint256 eventID, uint256 redeemNumTix) public VeriCreator returns(bool admit) {
    require(numTickets[userAddress][eventID] >= 1);
    if (numTickets[userAddress][eventID] >= redeemNumTix) {
        numTickets[userAddress][eventID] = numTickets[userAddress][eventID] - redeemNumTix;
        admit = true;
    } else if (numTickets[userAddress][eventID] < redeemNumTix) {
        admit = false;
        revert("Not enough tickets, please try again.");
    }
    return admit;
}

function transferTickets(address _to, uint256 eventID, uint256 transferValue) public regUser {
    require(transferValue <= numTickets[msg.sender][eventID], "Insufficient Ticket Balance!");
    numTickets[msg.sender][eventID] = numTickets[msg.sender][eventID] - transferValue;                  // Deducts the transfer tickets out of the sender's account
    numTickets[_to][eventID] = numTickets[_to][eventID] + transferValue;                                // Adds the transfer tickets to the receiver's account 
}


}
