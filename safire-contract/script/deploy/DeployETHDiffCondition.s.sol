// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../../src/conditions/ETHDiffCondition.sol";

contract DeployETHDiffCondition is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Price Feeds For Base Sepolia Testnet
        // ETH/USD => 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1

        new ETHDiffCondition(0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1);

        vm.stopBroadcast();
    }
}
