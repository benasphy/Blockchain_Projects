// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleStorage
 * @author You
 * @notice Stores and updates a single uint value
 */
contract SimpleStorage {
    uint256 private storedValue;

    /// @notice Emitted when value is updated
    event ValueUpdated(uint256 oldValue, uint256 newValue);

    /// @notice Store a new value
    function set(uint256 _value) external {
        uint256 oldValue = storedValue;
        storedValue = _value;

        emit ValueUpdated(oldValue, _value);
    }

    /// @notice Retrieve stored value
    function get() external view returns (uint256) {
        return storedValue;
    }
}
