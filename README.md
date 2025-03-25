# Düşük Ücretli ERC20 Token Fabrikası

Bu proje, Sepolia test ağında çalışan ve düşük ücretlerle ERC20 token oluşturmanıza olanak sağlayan bir token fabrikası içerir.

## Özellikler

- **Güvenli ERC20 Token**: Anti-whale mekanizması, kara liste, bekleme süresi ve maksimum işlem limitlerine sahip
- **Token Fabrikası**: Özelleştirilebilir token'lar oluşturmak için fabrika kontratı
- **Düşük Ücretler**: Sepolia ağında kullanım için optimize edilmiş düşük ücretler

## Kurulum

1. Projeyi klonlayın:
```
git clone <repo-url>
cd <repo-directory>
```

2. Bağımlılıkları yükleyin:
```
npm install
```

3. `.env.example` dosyasını `.env` olarak kopyalayın ve gerekli bilgileri ekleyin:
```
cp .env.example .env
```

4. `.env` dosyasını düzenleyin:
   - `SEPOLIA_RPC_URL`: Sepolia RPC URL'inizi ekleyin (Infura, Alchemy vb.)
   - `PRIVATE_KEY`: Metamask veya başka bir cüzdandan özel anahtarınızı ekleyin
   - `ETHERSCAN_API_KEY`: Kontrat doğrulama için Etherscan API anahtarınızı ekleyin

## Deployment

Sepolia test ağına deploy etmek için:

```
npx hardhat run scripts/deploy-sepolia.js --network sepolia
```

## Token Oluşturma

1. Deployment sonrasında verilen kontrat adresini kaydedin
2. Metamask'te Sepolia test ağına bağlanın
3. Kontrat adresini kullanarak ERC20Factory ile etkileşime geçin:
   - `createToken` fonksiyonunu çağırın
   - Gerekli parametreleri ve değeri (0.0015 ETH) gönderin
   - Token'ınız oluşturulacak ve adresinize kaydedilecektir

## Ücretler

- Token oluşturma: 0.001 ETH
- Kara liste özelliği: 0.0005 ETH ek ücret

## Kontrat Doğrulama

Deploy script çalıştırıldıktan sonra, kontratı Etherscan'de doğrulamak için:

```
npx hardhat verify --network sepolia <DEPLOYED_CONTRACT_ADDRESS> <YOUR_ADDRESS>
```

## Governance Token Kontratı

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract GovernanceToken is ERC20Votes {
    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
        ERC20Permit(name)
    {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // İlk arz
    }

    // Aşağıdaki işlevler ERC20Votes tarafından sağlanır ve geçersiz kılınmalıdır
    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
```