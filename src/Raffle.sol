// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

** @title Raffle Contract
 * @author Onchain DevRel
 * @version 1.0
 * @notice This contract is for creating a sample raffle system.
 * @dev Implements Chainlink VRFv2.5
 */

contract Raffle {

    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }
   function  enterRaffle()  public payable {

   }

   function pickWinner() public {

   }

}