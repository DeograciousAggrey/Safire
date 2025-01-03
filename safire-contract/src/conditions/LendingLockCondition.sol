// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../interfaces/ISafireCondition.sol";
import "../interfaces/ISafirePool.sol";
import "../interfaces/ICovidFunction.sol";
import "../interfaces/IETHPriceFeed.sol";
import "../interfaces/IBaseSepoliaMessenger.sol";

contract LendingLockCondition is ISafireCondition {
    IBaseSepoliaMessenger public baseSepolia_ccip;
    string public text;
    uint64 public destinationChainSelector;
    address public receiver;

    constructor(address _baseSepolia_ccip, uint64 _destinationChainSelector, address _receiver, string memory _text) {
        baseSepolia_ccip = IBaseSepoliaMessenger(_baseSepolia_ccip);
        destinationChainSelector = _destinationChainSelector;
        receiver = _receiver;
        text = _text;
    }

    // callCheckLendingStatus
    function callCheckLendingStatus() external {
        baseSepolia_ccip.sendMessagePayLINK(destinationChainSelector, receiver, text);
    }

    function checkUnlockClaim(address target) external override {
        // isLendingDemo = true => lending is locked or paused
        if (baseSepolia_ccip.isLendingDemo()) {
            ISafirePool(target).unlockClaim();
        }
    }

    function checkUnlockTerminate(address target) external override {
        ISafirePool(target).unlockTerminate();
    }
}
