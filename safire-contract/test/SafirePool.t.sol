// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/SafireFactory.sol";
import "../src/SafirePool.sol";
import "../src/conditions/SimpleCondition.sol";
import "./contracts/TestERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract SafirePoolTest is Test {
    SafireFactory public factory;
    SafirePool public safirePool;
    SimpleCondition public condition;
    TestERC20 public testERC20;

    uint256 private _multiplier = 10000000; // 3x
    uint256 private _multiplierDecimals = 6;

    enum State {
        Ongoing,
        Claimable,
        Matured,
        Terminated
    }

    // Events
    event InsuranceBought(address indexed buyer, address token, uint256 amount);
    event InsuranceSold(address indexed seller, address token, uint256 amount);
    event StateChanged(State oldState, State newState);
    event Withdrew(address token, uint256 amount, address indexed to);

    function setUp() public {
        testERC20 = new TestERC20();
        testERC20.mint(address(this), 1000000 * 10 ** testERC20.decimals());
        testERC20.mint(address(1), 1000000 * 10 ** testERC20.decimals());

        factory = new SafireFactory();
        condition = new SimpleCondition();

        uint256 _maturityBlock = 100;
        uint256 _staleBlock = 90;
        address _underlyingToken = address(testERC20);
        uint256 _fee = 1000; // 0.01 = 1%
        address _feeTo = address(this);

        string memory _name = "Covid Insurance";
        string memory _symbol = "COVID";

        address _pool = factory.createSafireContract(
            _multiplier, _maturityBlock, _staleBlock, _underlyingToken, _fee, _feeTo, address(condition), _name, _symbol
        );
        safirePool = SafirePool(_pool);
    }

    function testSellInsurance() public {
        uint256 _amount = 100 * 10 ** testERC20.decimals();

        testERC20.approve(address(safirePool), _amount);
        safirePool.sellInsurance(_amount);

        assertEq(safirePool.totalValueLocked(), _amount);
        assertEq(IERC20(safirePool.sellerToken()).balanceOf(address(this)), _amount);
    }

    function testBuyInsurance() public {
        uint256 _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(safirePool), _amount * _multiplier / 10 ** _multiplierDecimals);
        safirePool.sellInsurance(_amount * _multiplier / 10 ** _multiplierDecimals);

        vm.stopPrank();
        testERC20.approve(address(safirePool), _amount);
        safirePool.buyInsurance(_amount);

        assertEq(safirePool.totalValueLocked(), _amount + _amount * _multiplier / 10 ** _multiplierDecimals);
        assertEq(IERC20(safirePool.buyerToken()).balanceOf(address(this)), _amount);
    }

    function testFail_BuyInsuranceExceedMax() public {
        uint256 _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(safirePool), _amount * 2);
        safirePool.sellInsurance(_amount * 2);

        vm.stopPrank();
        testERC20.approve(address(safirePool), _amount);
        safirePool.buyInsurance(_amount);

        testERC20.approve(address(safirePool), _amount);
        safirePool.buyInsurance(_amount + 1);
    }

    function testFail_BuyInsuranceInStaleTime() public {
        uint256 _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(safirePool), _amount * 2);
        safirePool.sellInsurance(_amount * 2);

        vm.stopPrank();
        testERC20.approve(address(safirePool), _amount);
        safirePool.buyInsurance(_amount);

        vm.roll(91);

        testERC20.approve(address(safirePool), _amount);
        safirePool.buyInsurance(_amount);
    }

    function testChangeStateToClaimable() public {
        safirePool.checkUnlockClaim();
    }

    function testChangeStateToMatured() public {
        vm.roll(101);
        safirePool.unlockMaturity();
    }

    function testChangeStateToTerminate() public {
        safirePool.checkUnlockTerminate();
    }

    function testFail_ChangeStateFromClaimableToMatured() public {
        safirePool.checkUnlockClaim();
        safirePool.unlockMaturity();
    }

    function testFail_ChangeStateFromMaturedToClaimable() public {
        safirePool.unlockMaturity();
        safirePool.checkUnlockClaim();
    }

    // Test withdraw on claimable - check seller and buyer token amount
    function testWithdrawClaimable() public {
        uint256 _initialBalance = 1000000 * 10 ** testERC20.decimals();

        uint256 _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(safirePool), _amount * _multiplier / 10 ** _multiplierDecimals);
        safirePool.sellInsurance(_amount * _multiplier / 10 ** _multiplierDecimals);

        vm.stopPrank();
        testERC20.approve(address(safirePool), _amount);
        safirePool.buyInsurance(_amount);

        IERC20 sellerToken = IERC20(safirePool.sellerToken());
        IERC20 buyerToken = IERC20(safirePool.buyerToken());

        safirePool.checkUnlockClaim();

        vm.startPrank(address(1));
        sellerToken.approve(address(safirePool), sellerToken.balanceOf(address(1)));
        safirePool.withdraw(0, sellerToken.balanceOf(address(1)));
        uint256 sellerBalanceAfter = testERC20.balanceOf(address(1));
        vm.stopPrank();

        buyerToken.approve(address(safirePool), buyerToken.balanceOf(address(this)));
        safirePool.withdraw(buyerToken.balanceOf(address(this)), 0);
        uint256 buyerBalanceAfter = testERC20.balanceOf(address(this));

        assertLt(sellerBalanceAfter, _initialBalance);
        assertGt(buyerBalanceAfter, _initialBalance);
    }

    // Test withdraw on matured
    function testWithdrawMatured() public {
        uint256 _initialBalance = 1000000 * 10 ** testERC20.decimals();

        uint256 _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(safirePool), _amount * _multiplier / 10 ** _multiplierDecimals);
        safirePool.sellInsurance(_amount * _multiplier / 10 ** _multiplierDecimals);

        vm.stopPrank();
        testERC20.approve(address(safirePool), _amount);
        safirePool.buyInsurance(_amount);

        IERC20 sellerToken = IERC20(safirePool.sellerToken());
        IERC20 buyerToken = IERC20(safirePool.buyerToken());

        vm.roll(101);
        safirePool.unlockMaturity();

        vm.startPrank(address(1));
        sellerToken.approve(address(safirePool), sellerToken.balanceOf(address(1)));
        safirePool.withdraw(0, sellerToken.balanceOf(address(1)));
        uint256 sellerBalanceAfter = testERC20.balanceOf(address(1));
        vm.stopPrank();

        buyerToken.approve(address(safirePool), buyerToken.balanceOf(address(this)));
        safirePool.withdraw(buyerToken.balanceOf(address(this)), 0);
        uint256 buyerBalanceAfter = testERC20.balanceOf(address(this));

        assertLt(buyerBalanceAfter, _initialBalance);
        assertGt(sellerBalanceAfter, _initialBalance);
    }

    // Test withdraw on terminated
    function testWithdrawTerminated() public {
        uint256 _initialBalance = 1000000 * 10 ** testERC20.decimals();

        uint256 _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(safirePool), _amount * _multiplier / 10 ** _multiplierDecimals);
        safirePool.sellInsurance(_amount * _multiplier / 10 ** _multiplierDecimals);

        vm.stopPrank();
        testERC20.approve(address(safirePool), _amount);
        safirePool.buyInsurance(_amount);

        IERC20 sellerToken = IERC20(safirePool.sellerToken());
        IERC20 buyerToken = IERC20(safirePool.buyerToken());

        safirePool.checkUnlockTerminate();

        vm.startPrank(address(1));
        sellerToken.approve(address(safirePool), sellerToken.balanceOf(address(1)));
        safirePool.withdraw(0, sellerToken.balanceOf(address(1)));
        uint256 sellerBalanceAfter = testERC20.balanceOf(address(1));
        vm.stopPrank();

        buyerToken.approve(address(safirePool), buyerToken.balanceOf(address(this)));
        safirePool.withdraw(buyerToken.balanceOf(address(this)), 0);
        uint256 buyerBalanceAfter = testERC20.balanceOf(address(this));

        assertEq(buyerBalanceAfter, _initialBalance);
        assertEq(sellerBalanceAfter, _initialBalance);
    }
}
