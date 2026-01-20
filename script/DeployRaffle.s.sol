// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./interactions.s.sol";

contract DeployRaffle is Script {
    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig
            .getConfig();

        if (networkConfig.subscriptionId == 0) {
            // Create subscription
            CreateSubscription createSubscription = new CreateSubscription();

            (
                networkConfig.subscriptionId,
                networkConfig.vrfCoordinatorV2_5
            ) = createSubscription.createSubscription(
                networkConfig.vrfCoordinatorV2_5,
                msg.sender
            );

            // Fund subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                networkConfig.vrfCoordinatorV2_5,
                networkConfig.subscriptionId,
                networkConfig.link,
                networkConfig.account
            );
        }

        vm.startBroadcast(networkConfig.account);
        Raffle raffle = new Raffle(
            networkConfig.subscriptionId,
            networkConfig.gasLane,
            networkConfig.automationUpdateInterval,
            networkConfig.raffleEntranceFee,
            networkConfig.callbackGasLimit,
            networkConfig.vrfCoordinatorV2_5
        );
        vm.stopBroadcast();

        // Add Consumer
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            networkConfig.vrfCoordinatorV2_5,
            networkConfig.subscriptionId,
            networkConfig.account
        );

        return (raffle, helperConfig);
    }
}
