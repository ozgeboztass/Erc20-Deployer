// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract SecureERC20Token is ERC20, ERC20Permit, ERC20Burnable, Pausable, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    uint256 public maxTxAmount;
    uint256 public maxWalletBalance;
    uint256 public cooldownTime = 30 seconds;
    mapping(address => uint256) private _lastTxTime;
    EnumerableSet.AddressSet private _blacklisted;
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address initialOwner,
        uint256 _maxTxAmount,
        uint256 _maxWalletBalance
    ) ERC20(name, symbol) ERC20Permit(name) Ownable(initialOwner) {
        _mint(initialOwner, initialSupply);
        maxTxAmount = _maxTxAmount;
        maxWalletBalance = _maxWalletBalance;
    }
    
    function addToBlacklist(address account) external onlyOwner {
        _blacklisted.add(account);
    }
    
    function removeFromBlacklist(address account) external onlyOwner {
        _blacklisted.remove(account);
    }
    
    function setCooldownTime(uint256 time) external onlyOwner {
        cooldownTime = time;
    }
    
    function pause() public onlyOwner {
        _pause();
    }
    
    function unpause() public onlyOwner {
        _unpause();
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(!paused(), "Token transfers paused");
        require(
            !_blacklisted.contains(from) && 
            !_blacklisted.contains(to) &&
            !_blacklisted.contains(msg.sender),
            "Blacklisted address"
        );
        
        // Anti-whale mechanism
        if(to != address(0)) {
            require(
                balanceOf(to) + amount <= maxWalletBalance, 
                "Exceeds max wallet balance"
            );
        }
        
        // Cooldown control (except for owner and zero address)
        if(from != owner() && to != owner() && msg.sender != owner() && from != address(0)) {
            require(
                _lastTxTime[msg.sender] + cooldownTime <= block.timestamp, 
                "Cooldown active"
            );
            _lastTxTime[msg.sender] = block.timestamp;
        }
        
        require(amount <= maxTxAmount, "Exceeds maximum transaction amount");
        
        super._beforeTokenTransfer(from, to, amount);
    }
} 