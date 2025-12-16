// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CustomERC20.sol";

contract CustomERC20Test is Test {
    CustomERC20 token;
    address alice = address(1);
    address bob = address(2);

    function setUp() public {
        token = new CustomERC20(
            "Custom Token",
            "CTK",
            6,
            1_000_000 * 10**6;
        );
    }

    function testDecimals() public view {
        assertEq(token.decimals(), 6);
    }

    function testTransferWithoutFee() public {
        token.transfer(alice, 1000);
        assertEq(token.balanceOf(alice), 1000);
    }

    function testTransferWithFee() public {
        token.setTransferFee(100); // 1%

        token.transfer(alice, 1000);

        assertEq(token.balanceOf(alice), 990);
        assertEq(token.balanceOf(token.owner()), 1_000_000 * 10**6 - 1000 + 10);
    }

    function testFeeExempt() public {
        token.setTransferFee(200);
        token.setFeeExempt(alice, true);

        token.transfer(alice, 1000);
        vm.prank(alice);
        token.transfer(bob, 1000);

        assertEq(token.balanceOf(bob), 1000);
    }
}
