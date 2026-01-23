// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from
    "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/unit/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

/*//////////////////////////////////////////////////////////////
                        CREATE SUBSCRIPTION
//////////////////////////////////////////////////////////////*/
contract CreateSubscription is Script {
    function run() external {
        createSubscriptionUsingConfig();
    }

    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinatorV2_5;
        address account = helperConfig.getConfig().account;
        return createSubscription(vrfCoordinator, account);
    }
    function createSubscription(address vrfCoordinator, address account) public returns (uint256 subId, address) {
        console.log("Creating subscription...");
        console.log("Chain ID:", block.chainid);

        vm.startBroadcast(account);
        subId =
            VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        console.log("Subscription created with ID:", subId);
        console.log("Update subscriptionId in HelperConfig.s.sol");

        return (subId, vrfCoordinator);
    }
}

/*//////////////////////////////////////////////////////////////
                        FUND SUBSCRIPTION
//////////////////////////////////////////////////////////////*/
contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function run() external {
        fundSubscriptionUsingConfig();
    }

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        fundSubscription(
            config.vrfCoordinatorV2_5,
            config.subscriptionId,
            config.link,
            config.account
        );
    }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address linkToken,
        address account
    ) public {
        console.log("Funding subscription:", subscriptionId);
        console.log("VRF Coordinator:", vrfCoordinator);
        console.log("Chain ID:", block.chainid);

        

        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT * 100
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }

        

        console.log("Subscription funded");
    }
}

/*//////////////////////////////////////////////////////////////
                        ADD CONSUMER
//////////////////////////////////////////////////////////////*/
contract AddConsumer is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(mostRecentlyDeployed);
    }

    function addConsumerUsingConfig(address consumer) public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        addConsumer(
            consumer,
            config.vrfCoordinatorV2_5,
            config.subscriptionId,
            config.account
        );
    }

    function addConsumer(
        address consumer,
        address vrfCoordinator,
        uint256 subscriptionId,
        address account
    ) public {
        console.log("Adding consumer:", consumer);
        console.log("Subscription ID:", subscriptionId);

        vm.startBroadcast(account);
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subscriptionId,
            consumer
        );
        vm.stopBroadcast();

        console.log("Consumer added successfully");
    }
}
