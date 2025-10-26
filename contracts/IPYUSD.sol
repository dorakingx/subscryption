// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IPYUSD
 * @dev Interface for PYUSD (PayPal USD) ERC20 token with Permit extension
 */
interface IPYUSD {
    /**
     * @dev Returns the total supply of tokens
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the balance of tokens for a given account
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Transfers tokens from the caller to a recipient
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining allowance that a spender can withdraw
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Approves a spender to transfer tokens on behalf of the caller
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Transfers tokens from one address to another using allowance
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when tokens are transferred
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when allowance is changed
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Permit extension for ERC20 token
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
