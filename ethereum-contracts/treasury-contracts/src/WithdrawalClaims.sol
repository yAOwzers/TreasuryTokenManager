// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin ERC20 interface for token interactions
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WithdrawalContract {
    // Struct to represent a withdrawal claim
    struct WithdrawalClaim {
        address claimant; // Address of the claimant
        uint256 amount; // Amount of tokens requested
        uint256 approvalsCount; // Number of approvals received
        mapping(address => bool) approvals; // Mapping of managers who approved
        bool canWithdraw; // Flag to track if the claim can be withdrawn
        bool executed; // Flag to track if the claim has been executed
    }

    // Define roles
    enum Role {
        None,
        Employee,
        Manager
    }

    // Mapping from employee address to Employee details
    mapping(address => Role) public employees;

    // Mapping from claim ID to WithdrawalClaim
    mapping(uint256 => WithdrawalClaim) public claims;

    // Counter for generating unique claim IDs
    uint256 public claimCount;

    // Address of the ERC20 token contract
    address public tokenAddress;

    // ERC20 token contract interface
    IERC20 public token;

    // max spending
    uint256 private constant MAX_APPROVAL = 1000;

    // Mapping to store roles of users
    // mapping(address => bool) public isManager;

    // Modifier to restrict functions to managers only
    modifier onlyManager() {
        require(
            employees[msg.sender] == Role.Manager,
            "Only managers can call this function"
        );
        _;
    }

    // Event emitted when a new employee is added
    event NewEmployee(address indexed account, Role role);

    // Event emitted when a new withdrawal claim is created
    event NewWithdrawalClaim(
        uint256 indexed claimId,
        address indexed claimant,
        uint256 amount
    );

    // Event emitted when a claim is approved by a manager
    event ClaimApproved(uint256 indexed claimId, address indexed manager);

    // Event emitted when a claim is executed
    event ClaimExecuted(
        uint256 indexed claimId,
        address indexed claimant,
        uint256 amount
    );

    // Event emitted when a claim is withdrawn
    event ClaimWithdrawn(
        uint256 indexed claimId,
        address indexed claimant,
        uint256 amount
    );

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        token = IERC20(tokenAddress);
        // approve the spending
        // token.approve(address(this), MAX_APPROVAL);

        // TODO: i dont think this will pass through, so might need to manually transfer the tokens
        // token.transferFrom(msg.sender, address(this), 1000000 * 10 ** ERC20(_tokenAddress).decimals());
        // Assume deployer of the contract is the initial manager
        employees[msg.sender] = Role.Manager;
    }

    // Function to add a new employee
    function addEmployee(address _account, Role _role) public onlyManager {
        require(_role != Role.None, "Invalid role");
        require(employees[_account] == Role.None, "Employee already exists");

        employees[_account] = Role(_role);

        emit NewEmployee(_account, _role);
    }

    // Function to create a new withdrawal claim
    function createWithdrawalClaim(
        address claimantAddress,
        uint256 _amount
    ) external {
        require(_amount > 0, "Amount must be greater than zero");

        uint256 newClaimId = claimCount++;
        WithdrawalClaim storage newWithdrawalClaim = claims[newClaimId];
        newWithdrawalClaim.claimant = claimantAddress;
        newWithdrawalClaim.amount = _amount;
        newWithdrawalClaim.approvalsCount = 0;
        newWithdrawalClaim.canWithdraw = false;
        newWithdrawalClaim.executed = false;

        emit NewWithdrawalClaim(newClaimId, claimantAddress, _amount);
    }

    // Function for claimants to withdraw approved claims
    function withdrawClaim(uint256 _claimId) external {
        require(
            claims[_claimId].canWithdraw,
            "Claim not approved for withdrawal"
        );
        require(!claims[_claimId].executed, "Claim already executed");
        require(
            claims[_claimId].claimant == msg.sender,
            "Only claimant can withdraw"
        );

        // Transfer tokens to the claimant
        token.transfer(claims[_claimId].claimant, claims[_claimId].amount);

        claims[_claimId].executed = true;

        emit ClaimWithdrawn(
            _claimId,
            claims[_claimId].claimant,
            claims[_claimId].amount
        );
    }

    function getClaims() public view returns (uint[] memory) {
        uint[] memory claimIds = new uint[](claimCount);
        uint counter = 0;
        for (uint i = 0; i < claimCount; i++) {
            if (claims[i].executed) {
                continue;
            }
            claimIds[counter] = i;
            counter++;
        }
        return claimIds;
    }

    function getClaim(
        uint256 claimId
    )
        public
        view
        returns (
            address claimant,
            uint256 amount,
            uint256 approvalsCount,
            bool canWithdraw,
            bool executed
        )
    {
        return (
            claims[claimId].claimant,
            claims[claimId].amount,
            claims[claimId].approvalsCount,
            claims[claimId].canWithdraw,
            claims[claimId].executed
        );
    }

    function hasManagerApproved(
        uint256 claimId,
        address managerAddress
    ) public view returns (bool hasApproved) {
        return claims[claimId].approvals[managerAddress];
    }

    // Function for managers to approve a withdrawal claim
    function approveClaim(uint256 _claimId) external onlyManager {
        require(!claims[_claimId].executed, "Claim already executed");
        require(!claims[_claimId].approvals[msg.sender], "Already approved");

        claims[_claimId].approvals[msg.sender] = true;
        claims[_claimId].approvalsCount++;

        emit ClaimApproved(_claimId, msg.sender);

        // If two approvals are received, set canWithdraw to true
        if (claims[_claimId].approvalsCount == 2) {
            claims[_claimId].canWithdraw = true;
        }
    }

    // Internal function to execute a withdrawal claim
    // function executeClaim(uint256 _claimId) internal {
    //     require(!claims[_claimId].executed, "Claim already executed");

    //     // Transfer tokens to the claimant
    //     token = IERC20(tokenAddress);
    //     token.transferFrom(claims[_claimId].claimant, claims[_claimId].claimant, claims[_claimId].amount);

    //     claims[_claimId].executed = true;

    //     emit ClaimExecuted(_claimId, claims[_claimId].claimant, claims[_claimId].amount);
    // }

    // Function to add a new manager
    function addManager(address _manager) external onlyManager {
        require(
            employees[_manager] == Role.Manager,
            "Address is already a manager"
        );
        employees[_manager] = Role.Manager;
    }

    // Function to remove a manager
    function removeManager(address _manager) external onlyManager {
        // Ensure at least one manager remains
        require(
            msg.sender != _manager,
            "Cannot remove yourself while still being a manager"
        );
        employees[_manager] = Role.Employee;
    }

    function getCurrentBalance(
        address requesterAddress
    ) public view returns (uint256 balance) {
        // check if requester inside list of employees
        require(
            employees[requesterAddress] == Role.None,
            "Address does not exist in Employee database"
        );

        return token.balanceOf(requesterAddress);
    }
}
