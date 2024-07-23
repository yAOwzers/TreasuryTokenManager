// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "truffle/Assert.sol";
// import "truffle/DeployedAddresses.sol";
// import "../contracts/CompanyToken.sol";
// import "../contracts/WithdrawalClaims.sol";

// contract TestWithdrawalClaims {
//     CompanyToken companyToken;
//     WithdrawalClaims withdrawalClaims;

//     function beforeEach() public {
//         companyToken = new CompanyToken();
//         withdrawalClaims = new WithdrawalClaims(address(companyToken));
//     }

//     function testCreateClaim() public {
//         uint amount = 100;
//         uint claimId = withdrawalClaims.createClaim(amount);
//         Assert.equal(
//             withdrawalClaims.claims(claimId).claimant(),
//             address(this),
//             "Claimant should match"
//         );
//         Assert.equal(
//             withdrawalClaims.claims(claimId).amount(),
//             amount,
//             "Claim amount should match"
//         );
//     }

//     function testApproveClaim() public {
//         uint amount = 100;
//         uint claimId = withdrawalClaims.createClaim(amount);
//         withdrawalClaims.approveClaim(claimId);
//         Assert.equal(
//             withdrawalClaims.claims(claimId).approved(),
//             true,
//             "Claim should be approved"
//         );
//     }

//     function testWithdraw() public {
//         uint amount = 100;
//         uint claimId = withdrawalClaims.createClaim(amount);
//         withdrawalClaims.approveClaim(claimId);
//         withdrawalClaims.withdraw(claimId);
//         Assert.equal(
//             companyToken.balanceOf(address(this)),
//             expected + amount,
//             "Balance should increase after withdrawal"
//         );
//     }
// }
