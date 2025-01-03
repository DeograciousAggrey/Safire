// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../interfaces/ISafireCondition.sol";
import "../interfaces/ISafirePool.sol";
import "../interfaces/ICovidFunction.sol";
import "../interfaces/IETHPriceFeed.sol";

contract ETHBelowCondition is ISafireCondition {
    IETHPriceFeed public dataFeed;

    constructor(address _dataFeed) {
        dataFeed = IETHPriceFeed(_dataFeed);
    }

    function checkUnlockClaim(address target) external override {
        // eth price below 100 usd
        if (dataFeed.isBelow100USD()) {
            ISafirePool(target).unlockClaim();
        }
    }

    function checkUnlockTerminate(address target) external override {
        ISafirePool(target).unlockTerminate();
    }
}
