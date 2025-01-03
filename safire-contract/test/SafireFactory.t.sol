// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/SafireFactory.sol";
import "../src/SafirePool.sol";
import "../src/conditions/SimpleCondition.sol";
import "./contracts/TestERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract SafireFactoryTest is Test {
    SafireFactory public factory;
    SimpleCondition public condition;
    TestERC20 public testERC20;

    uint256 private _multiplier = 10000000; // 3x
    uint256 private _multiplierDecimals = 6;

    uint256 private _maturityBlock = 100;
    uint256 private _staleBlock = 90;
    uint256 private _fee = 1000; // 0.01 = 1%
    address private _feeTo = address(this);

    string private _name = "Covid Insurance";
    string private _symbol = "COVID";

    function setUp() public {
        testERC20 = new TestERC20();
        condition = new SimpleCondition();
        factory = new SafireFactory();
    }

    function testCreateSafire() public {
        address pool = factory.createSafireContract(
            _multiplier,
            _maturityBlock,
            _staleBlock,
            address(testERC20),
            _fee,
            _feeTo,
            address(condition),
            _name,
            _symbol
        );
        assertNotEq(pool, address(0));
    }
}
