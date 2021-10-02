// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/ERC20Burnable.sol";
import "./utils/SafeMath.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract JSN is ERC20Burnable, Ownable {
    using SafeMath for uint256;

    uint256 public _minimumSupply = 0;
    uint8   public _burnRate = 1;
    mapping(address => uint8) public lockList;
    mapping(address => uint8) public whiteAddress;
    mapping(address => uint256) public lockAmount;
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
        _mint(0xff098373a0a8a36cb2e30b975328B2d8E218b22c, 980000 * 10**18);  //initialamount = 980,000
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (lockList[msg.sender] == 1) {
        require (balanceOf(msg.sender).sub(amount) >= lockAmount[msg.sender],  "amount locked");
        }
        if (whiteAddress[msg.sender] == 1 || whiteAddress[recipient] == 1){
        _transfer(msg.sender, recipient, amount);
        return true;
        }
        uint256 amountafterBurn = _amountafterBurn(msg.sender, amount);
        _transfer(msg.sender, recipient, amountafterBurn);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if (lockList[sender] == 1) {
        require (balanceOf(sender).sub(amount) >= lockAmount[sender],  "amount locked");
        }
        if (whiteAddress[msg.sender] == 1 || whiteAddress[recipient] == 1){
        _transfer(sender, recipient, amount);
        uint256 allowance = allowance(sender, msg.sender);
        _approve(sender, msg.sender, allowance.sub(amount, "JSN: TRANSFER_AMOUNT_EXCEEDED"));      
        return true;
        }
        uint256 amountafterBurn = _amountafterBurn(sender, amount);
        _transfer(sender, recipient, amountafterBurn);
        uint256 allowance = allowance(sender, msg.sender);
        _approve(sender, msg.sender, allowance.sub(amount, "JSN: TRANSFER_AMOUNT_EXCEEDED"));
        return true;
    }

    function _amountafterBurn(address from, uint256 amount) internal returns (uint256) {
        uint256 burnAmount = _calculateBurnAmount(amount);

        if (burnAmount > 0) {
            _burn(from, burnAmount);
        }

        return amount.sub(burnAmount);
    }

    function _calculateBurnAmount(uint256 amount)
        internal
        view
        returns (uint256)
    {
        uint256 burnAmount = 0;
        // burn amount calculations
        if (totalSupply() > _minimumSupply) {
            burnAmount = amount.mul(_burnRate).div(100);
            uint256 availableBurn = totalSupply().sub(_minimumSupply);
            if (burnAmount > availableBurn) {
                burnAmount = availableBurn;
            }
        }

        return burnAmount;
    }


    function mintToken(address recipient, uint256 amount) onlyOwner external {
        _mint(recipient, amount);
        require(totalSupply() <= 98 * 10**6 * 10**18, "JSN: TOTAL_SUPPLY_EXCEEDED");
    }

    function burn(uint256 amount) public override  {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        override
    {
        super.burnFrom(account, amount);
    }


    function setLock(address account, uint8 stats, uint256 amount)
        onlyOwner external
    {
        lockList[account] = stats;
        lockAmount[account] = amount;
    }

    function setwhiteAddress(address account, uint8 stats)
        onlyOwner external
    {
        whiteAddress[account] = stats;
    }


    function setMinimumSupply(uint256 amount) external onlyOwner {
        _minimumSupply = amount;
    }

    function setBurnRate(uint8 rate) external onlyOwner {
        _burnRate = rate;
    }




}
