// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import "../../src/dataProviders/BaseSepoliaMessenger.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract DeployBaseSepoliaMessenger is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // rounter ccip on baseSepolia => 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93
        // link token on baseSepolia => 0xE4aB69C077896252FAFBD49EFD26B5D171A32410

        BaseSepoliaMessenger messenger = new BaseSepoliaMessenger(
            0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93, 0xE4aB69C077896252FAFBD49EFD26B5D171A32410
        );

        // onwer address tranfer link to messenger Contract
        IERC20Metadata link = IERC20Metadata(0xE4aB69C077896252FAFBD49EFD26B5D171A32410);
        // fill 2 link token to messenger contract for link fee
        link.transfer(address(messenger), 1 * 10 ** link.decimals());

        vm.stopBroadcast();
    }
}
