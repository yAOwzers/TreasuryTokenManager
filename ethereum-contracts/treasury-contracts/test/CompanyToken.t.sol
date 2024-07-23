// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/CompanyToken.sol";

contract TestCompanyToken {
    CompanyToken companyToken;

    function beforeEach() public {
        companyToken = new CompanyToken();
    }

    function testInitialBalance() public {
        uint expected = 1000000 * 10 ** companyToken.decimals();
        Assert.equal(
            companyToken.balanceOf(address(this)),
            expected,
            "Initial balance should match"
        );
    }

    function testMintTokens() public {
        uint amount = 1000;
        companyToken.mint(address(this), amount);
        Assert.equal(
            companyToken.balanceOf(address(this)),
            expected + amount,
            "Balance should increase after minting"
        );
    }

    function testTransfer() public {
        uint amount = 100;
        address recipient = address(0x1a230B0C13409110DCD00A67FD36Bf5Fd4cd110B); // Replace with actual recipient address
        companyToken.transfer(recipient, amount);
        Assert.equal(
            companyToken.balanceOf(address(this)),
            expected - amount,
            "Balance should decrease after transfer"
        );
        Assert.equal(
            companyToken.balanceOf(recipient),
            amount,
            "Recipient balance should increase after transfer"
        );
    }
}
