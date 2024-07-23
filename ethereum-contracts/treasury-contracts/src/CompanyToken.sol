// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract CompanyToken is ERC20 {
    address public owner;
    address public withdrawalContract; // Withdrawal contract address

    constructor() ERC20("CompanyToken", "CTK") {
        owner = msg.sender;
        _mint(msg.sender, 1000000 * (10 ** decimals()));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
