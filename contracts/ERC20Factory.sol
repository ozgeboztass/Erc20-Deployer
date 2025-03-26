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
    
    struct TokenConfig {
        uint256 maxTxAmount;
        uint256 maxWalletBalance;
        bool blacklistable;
        bool pausable;
        uint256 cooldownTime;
    }

    mapping(address => EnumerableSet.AddressSet) private _creatorTokens;
    mapping(string => bool) private _existingNames;
    mapping(string => bool) private _existingSymbols;
    EnumerableSet.AddressSet private _deployedTokens;
    
    uint256 public creationFee = 0.001 ether;
    address public feeRecipient;
    uint256 public antiBotFee = 0.0005 ether;

    constructor(address _feeRecipient) Ownable(msg.sender) {
        feeRecipient = _feeRecipient;
    }

    function createToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        TokenConfig memory config
    ) external payable nonReentrant returns (address) {
        require(msg.value >= creationFee + (config.blacklistable ? antiBotFee : 0), "Insufficient fee");
        require(!_existingNames[name], "Name exists");
        require(!_existingSymbols[symbol], "Symbol exists");
        
        // Excess ETH refund
        uint256 requiredFee = creationFee + (config.blacklistable ? antiBotFee : 0);
        if(msg.value > requiredFee) {
            payable(msg.sender).transfer(msg.value - requiredFee);
        }

        // Fee transfer
        (bool sent,) = feeRecipient.call{value: requiredFee}("");
        require(sent, "Fee transfer failed");

        SecureERC20Token token = new SecureERC20Token(
            name,
            symbol,
            initialSupply,
            msg.sender,
            config.maxTxAmount,
            config.maxWalletBalance
        );

        // Token configuration
        if(config.cooldownTime > 0) {
            token.setCooldownTime(config.cooldownTime);
        }

        // Registration operations
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