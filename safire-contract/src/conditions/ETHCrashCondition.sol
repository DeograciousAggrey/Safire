// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../interfaces/ISafireCondition.sol";
import "../interfaces/ISafirePool.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ETHCrashCondition is ISafireCondition {
    AggregatorV3Interface internal dataFeed;

    constructor() {
        // Fixed aggregator in BaseSepolia chain
        dataFeed = AggregatorV3Interface(0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1);
    }

    function getPrice() public view returns (int256) {
        (
            /* uint80 roundID */
            ,
            int256 answer,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function isEligible() public view returns (bool) {
        int256 price = getPrice();
        return price < 2500 * (10 ** 8);
    }

    function checkUnlockClaim(address target) external override {
        require(msg.sender == target, "Only target can check itself");
        if (isEligible()) {
            ISafirePool(target).unlockClaim();
        }
    }

    function checkUnlockTerminate(address target) external override {
        // For demo purpose only. Please add a strict condition on production
        ISafirePool(target).unlockTerminate();
    }
}
