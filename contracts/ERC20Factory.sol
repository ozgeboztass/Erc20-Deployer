// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./SecureERC20Token.sol";

contract ERC20Factory is Ownable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;

    event TokenCreated(address indexed tokenAddress, string name, address creator);

    mapping(address => EnumerableSet.AddressSet) private _creatorTokens;
    mapping(string => bool) private _existingNames;
    mapping(string => bool) private _existingSymbols;
    EnumerableSet.AddressSet private _deployedTokens;

    uint256 public creationFee = 0.001 ether;
    address public feeRecipient;
    uint256 public antiBotFee = 0.0005 ether;

    constructor() Ownable(msg.sender) {
        feeRecipient = msg.sender;
    }

    function createToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) external payable nonReentrant returns (address) {
        require(msg.value >= creationFee , "Insufficient fee");
        require(!_existingNames[name], "Name exists");
        require(!_existingSymbols[symbol], "Symbol exists");

        // Excess ETH refund
        uint256 requiredFee = creationFee ;
        if (msg.value > requiredFee) {
            payable(msg.sender).transfer(msg.value - requiredFee);
        }

        // Fee transfer
        (bool sent,) = feeRecipient.call{value: requiredFee}("");
        require(sent, "Fee transfer failed");

        SecureERC20Token token = new SecureERC20Token(
            name,
            symbol,
            initialSupply,
            msg.sender
        );

        // Register the new token
        _creatorTokens[msg.sender].add(address(token));
        _deployedTokens.add(address(token));
        _existingNames[name] = true;
        _existingSymbols[symbol] = true;

        emit TokenCreated(address(token), name, msg.sender);
        return address(token);
    }

    // Advanced security functions
    function setCreationFee(uint256 fee) external onlyOwner {
        creationFee = fee;
    }

    function setAntiBotFee(uint256 fee) external onlyOwner {
        antiBotFee = fee;
    }

    function withdrawStuckTokens(address tokenAddress) external onlyOwner {
        IERC20(tokenAddress).transfer(owner(), IERC20(tokenAddress).balanceOf(address(this)));
    }

    // View functions
    function getTokensByCreator(address creator) external view returns (address[] memory) {
        return _creatorTokens[creator].values();
    }

    function getAllTokens() external view returns (address[] memory) {
        return _deployedTokens.values();
    }
}
