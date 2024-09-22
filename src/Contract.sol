// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract ERC20 {
    using Strings for uint256;
    address immutable _owner;
    uint256 immutable _supply;
    uint8 _decimals;
    string _symbol;
    string _name;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) _allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialSupply,
        uint8 decimalUnits
    ) {
        _owner = msg.sender;
        _name = tokenName;
        _symbol = tokenSymbol;
        _supply = initialSupply;
        _decimals = decimalUnits;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _supply;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(
            balanceOf(msg.sender) >= value,
            string(
                abi.encodePacked(
                    "Transaction failed: Insufficient ",
                    _name,
                    " balance. Required: ",
                    value.toString(),
                    ", Available: ",
                    balanceOf(msg.sender).toString()
                )
            )
        );

        balances[msg.sender] = balances[msg.sender] - value;
        emit Transfer(msg.sender, to, value);
        balances[to] = balances[to] + value;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool success) {
        require(
            balanceOf(from) >= value,
            string(
                abi.encodePacked(
                    "Transaction failed: Insufficient ",
                    _name,
                    " balance. Required: ",
                    value.toString(),
                    ", Available: ",
                    balanceOf(from).toString()
                )
            )
        );

        // Corrected require statement to check if allowance is sufficient
        require(
            _allowance[from][msg.sender] >= value,
            string(
                abi.encodePacked(
                    "Transaction failed: Insufficient allowance of ",
                    _name,
                    ". Required: ",
                    value.toString(),
                    ", Allowed: ",
                    allowance(from, msg.sender).toString()
                )
            )
        );

        balances[from] = balances[from] - value;
        _allowance[msg.sender][from] = _allowance[msg.sender][from] - value;
        emit Transfer(from, to, value);
        balances[to] = balances[to] + value;
        return true;
    }

    function approve(
        address spender,
        uint256 value
    ) public returns (bool success) {
        require(
            balances[msg.sender] >= value,
            string(
                abi.encodePacked(
                    "Transaction failed: Insufficient ",
                    _name,
                    " balance. Required: ",
                    value.toString(),
                    ", Available: ",
                    balanceOf(msg.sender).toString()
                )
            )
        );

        // balances[msg.sender] = balances[msg.sender] - value;
        emit Approval(msg.sender, spender, value);
        _allowance[spender][msg.sender] =
            _allowance[spender][msg.sender] +
            value;
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256 remaining) {
        return _allowance[spender][owner];
    }
}
