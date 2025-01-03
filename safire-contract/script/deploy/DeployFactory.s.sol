// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/SafireFactory.sol"; // Path should go up to 'src'

contract DeployFactory is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new SafireFactory();

        vm.stopBroadcast();
    }
}
