// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ETHPriceFeed {
    AggregatorV3Interface internal dataFeed;

    int256 public startPrice;
    int256 public pricediff;
    bool public isBelow100USD;

    /**
     * Network: BaseSepolia
     * Aggregator: ETH/USD
     * Address: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1
     */
    constructor() {
        dataFeed = AggregatorV3Interface(0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1);
        (
            ,
            /* uint80 roundID */
            int256 answer,
            /*uint startedAt*/
            /*uint timeStamp*/
            /*uint80 answeredInRound*/
            ,
            ,
        ) = dataFeed.latestRoundData();
        startPrice = answer;
    }

    /**
     * Returns the latest answer.
     */
    function getPrice() public view returns (int256) {
        // prettier-ignore
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

    function calPrice() public returns (int256) {
        // prettier-ignore
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
        pricediff = ((startPrice - answer) / startPrice) * 100;
        if (answer < 100 * (10 ** 6)) {
            isBelow100USD = true;
        }
        return answer;
    }
}
