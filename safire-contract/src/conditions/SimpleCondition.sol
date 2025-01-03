// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../interfaces/ISafireCondition.sol";
import "../interfaces/ISafirePool.sol";

contract SimpleCondition is ISafireCondition {
    function checkUnlockClaim(address target) external override {
        ISafirePool(target).unlockClaim();
    }

    function checkUnlockTerminate(address target) external override {
        ISafirePool(target).unlockTerminate();
    }
}
