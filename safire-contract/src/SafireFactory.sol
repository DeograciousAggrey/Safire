// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./SafirePool.sol";

contract SafireFactory {
    event InsuranceCreated(address indexed creator, address indexed target, address indexed asset);

    function createSafireContract(
        uint256 multiplier_,
        uint256 maturityBlock_,
        uint256 staleBlock_,
        address asset_,
        uint256 fee_,
        address feeTo_,
        address condition_,
        string memory name_,
        string memory symbol_
    ) external returns (address) {
        SafirePool safirePool =
            new SafirePool(multiplier_, maturityBlock_, staleBlock_, asset_, fee_, feeTo_, condition_, name_, symbol_);
        emit InsuranceCreated(msg.sender, address(safirePool), asset_);
        return address(safirePool);
    }
}
