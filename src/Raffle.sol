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

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts@1.5.0/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

/* @title Raffle Contract
 * @author Onchain DevRel
 * @version 1.0
 * @notice This contract is for creating a sample raffle system.
 * @dev Implements Chainlink VRFv2.5 (placeholder)
 */
contract Raffle {
    /* Errors */
    error SendMoreToEnterRaffle();
    error RaffleNotReady();
    error NoPlayers();

    uint256 private immutable i_entranceFee;
    // @dev The duration of the lottery in seconds
    uint256 private immutable i_interval;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    /* Events */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner, uint256 amount);

    constructor(uint256 entranceFe, uint256 interval) {
        // Fix: use the correct parameter name entranceFe
        i_entranceFee = entranceFe;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // 1. Get random number (placeholder: timestamp-based, not secure)
    // 2. Use that number to pick a winner
    // 3. Send the money to the winner
    function pickWinner() external {
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert RaffleNotReady();
        }
        if (s_players.length == 0) {
            revert NoPlayers();
        }

           requestId = s_vrfCoordinator.requestRandomWords(
      VRFV2PlusClient.RandomWordsRequest({
        keyHash: s_keyHash,
        subId: s_subscriptionId,
        requestConfirmations: requestConfirmations,
        callbackGasLimit: callbackGasLimit,
        numWords: numWords,
        extraArgs: VRFV2PlusClient._argsToBytes(
          // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
          VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
        )
      })
    );

        uint256 indexOfWinner = block.timestamp % s_players.length;
        address payable winner = s_players[indexOfWinner];

        uint256 prize = address(this).balance;
        (bool success, ) = winner.call{value: prize}("");
        require(success, "Prize transfer failed");

        emit WinnerPicked(winner, prize);

        // reset the players array and timestamp
        delete s_players;
        s_lastTimeStamp = block.timestamp;
    }

    // View functions
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getInterval() external view returns (uint256) {
        return i_interval;
    }

    function getPlayers() external view returns (address payable[] memory) {
        return s_players;
    }

    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }
}

    