// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/CustomERC20.sol";

contract DeployERC20 is Script {
    function run() external {
        vm.startBroadcast();

        new CustomERC20(
            "Custom Token",
            "CTK",
            6,
            1_000_000 * 10**6
        );

        vm.stopBroadcast();
    }
}
