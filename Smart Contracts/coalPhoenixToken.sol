// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract coalPhoenixToken is ERC20, Ownable {

    using SafeMath for uint256;

    address public feeWallet;
    uint256 public fee = 0;

    mapping (address => bool) private _excludedWalletFee;

    event IssueTokens(address a, uint256 amount);
    event ExcludeFromFee(address indexed wallet, bool toggle);
    event ExcludeFromFee(address[] wallets, bool toggle);

    constructor(address fWallet) ERC20("CoalPhoenix", "COAX") {

        feeWallet = fWallet;

    }

    //Owner Only

    function issueTokens(uint256 amount) public onlyOwner {

        _mint(msg.sender, amount);

        emit IssueTokens(msg.sender, amount);

    }

    function burnTokens(uint256 amount) public onlyOwner {

        _burn(msg.sender, amount);
        
    }

    //Override

    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");

        //Send Fees
        if(!_excludedWalletFee[from] && !_excludedWalletFee[to] && fee > 0) {

            uint256 fees = amount.mul(fee).div(10000);
            amount = amount.sub(fees);

            super._transfer(from, feeWallet, fees);

        }

        super._transfer(from, to, amount);

    }

    // Getters

    function isExcludedFromFee(address wallet) public view returns (bool) {

        return _excludedWalletFee[wallet];

    }

    // Setters

    function excludeFromFee(address wallet, bool toggle) public onlyOwner {

        _excludedWalletFee[wallet] = toggle;

        emit ExcludeFromFee(wallet, toggle);

    }

    function excludeFromFee(address[] calldata wallets, bool toggle) public onlyOwner {

        for(uint256 i = 0; i < wallets.length; i++) {

            _excludedWalletFee[wallets[i]] = toggle;

        }

        emit ExcludeFromFee(wallets, toggle);

    }

    function setFeeWallet(address wallet) external onlyOwner { feeWallet = wallet; }

    function setFee(uint256 value) external onlyOwner { fee = value; }

}