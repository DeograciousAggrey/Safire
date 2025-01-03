// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import "../../src/dataProviders/AmoyMessenger.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract DeployAmoyMessenger is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // router ccip on amoy => 0x9C32fCB86BF0f4a1A8921a9Fe46de3198bb884B2
        // link token on amoy => 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904

        AMOYMessenger messenger = new AMOYMessenger(
            0x9C32fCB86BF0f4a1A8921a9Fe46de3198bb884B2, 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904, 16281711391670634445
        );

        // owner address tranfer link to messenger Contract
        IERC20Metadata link = IERC20Metadata(0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904);
        // fill 2 link token to messenger contract for link fee
        link.transfer(address(messenger), 1 * 10 ** link.decimals());

        vm.stopBroadcast();
    }
}
