// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage storageContract;

    function setUp() public {
        storageContract = new SimpleStorage();
    }

    function testInitialValueIsZero() public {
        uint256 value = storageContract.get();
        assertEq(value, 0);
    }

    function testSetAndGetValue() public {
        storageContract.set(42);
        uint256 value = storageContract.get();
        assertEq(value, 42);
    }

    function testEventEmittedOnUpdate() public {
        vm.expectEmit(true, true, true, true);
        emit SimpleStorage.ValueUpdated(0, 100);

        storageContract.set(100);
    }

    function testUpdateValue() public {
        storageContract.set(10);
        storageContract.set(25);

        uint256 value = storageContract.get();
        assertEq(value, 25);
    }
}
