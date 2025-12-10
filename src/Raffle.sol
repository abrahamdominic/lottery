// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/* @title Raffle Contract
 * @author Onchain DevRel
 * @version 1.0
 * @notice This contract is for creating a sample raffle system.
 * @dev Implements Chainlink VRFv2.5
 */

contract Raffle {
    /*Error*/ 
    error SendMoreToEnterRaffle();

    uint256 private immutable i_entranceFee;
    // @dev The duration of the lottery in seconds
    uint256 private immutable i_interval;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    /* Events */
    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFe, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }
   function  enterRaffle()  external payable {
    // require(msg.value >= i_entranceFee, "Not enough ETH to enter raffle");
    if (msg.value < i_entranceFee) {
        revert SendMoreToEnterRaffle();
    }
    s_players.push(payable(msg.sender));
    // 1. Make migration easier
    // 2. Makes front end "indexing easier"
    emit RaffleEntered(msg.sender);

   }

// 1. Get random number
// 2. Use that number to pick a winner
// 3. Send the money to the winner
   function pickWinner() external {
    // check to see if enough time has passed
    uint256 indexOfWinner =  block.timestamp % s_players.length;
    address payable winner = s_players[indexOfWinner];
    winner.transfer(address(this).balance);
    // reset the players array
    s_players = new address payable[](0);

   }

}