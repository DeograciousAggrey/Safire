// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import "../../src/conditions/LendingLockCondition.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployLendingLockCondition is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ///Needs more work

        new LendingLockCondition(
            // BaseSepoliaMessenger = BaseSepolia Sender contract address
            0x1515Fa830a4025436e9578d2f43542201feff208,
            // destinationChainSelector = amoy chain selector => https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet
            16281711391670634445,
            // receiver = amoymessenger receiver contract address
            0x1ebD1DD7CEFAE66661A90AF8C7bA2c18b6207E8F,
            // text => for check lending status
            "check_lending_status"
        );

        vm.stopBroadcast();
    }
}
