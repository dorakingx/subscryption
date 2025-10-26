// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IPYUSD.sol";

/**
 * @title PYUSDSubscription
 * @dev Smart contract for managing PYUSD-based subscription services
 * @notice Supports programmable payment logic, multiple subscription plans, and automatic renewals
 */
contract PYUSDSubscription is Ownable, ReentrancyGuard, Pausable {
    using SafeMath for uint256;

    // PYUSD token interface
    IPYUSD public pyusd;

    // Subscription plan structure
    struct SubscriptionPlan {
        string name;
        uint256 price; // Price in PYUSD (with decimals)
        uint256 billingPeriod; // Billing period in seconds (e.g., 2592000 for 30 days)
        uint256 maxSubscribers; // Maximum number of subscribers (0 for unlimited)
        bool active;
        uint256 currentSubscribers;
    }

    // User subscription information
    struct UserSubscription {
        uint256 planId;
        uint256 startTime;
        uint256 nextBillingDate;
        bool active;
        uint256 totalPaid; // Total amount paid by user
        uint256 renewalCount; // Number of renewals
    }

    // State variables
    SubscriptionPlan[] public plans;
    mapping(address => UserSubscription) public subscriptions;
    mapping(address => bool) public authorizedPullers; // Addresses authorized to pull payments

    // Events
    event PlanCreated(uint256 indexed planId, string name, uint256 price, uint256 billingPeriod);
    event PlanUpdated(uint256 indexed planId, bool active);
    event Subscribed(address indexed subscriber, uint256 indexed planId, uint256 startTime);
    event PaymentProcessed(address indexed subscriber, uint256 indexed planId, uint256 amount);
    event SubscriptionCancelled(address indexed subscriber);
    event SubscriptionExpired(address indexed subscriber, uint256 indexed planId);
    event PullerAuthorized(address indexed puller, bool authorized);
    event RefundProcessed(address indexed subscriber, uint256 amount);

    /**
     * @dev Custom SafeMath library for uint256
     */
    library SafeMath {
        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            require(c >= a, "SafeMath: addition overflow");
            return c;
        }

        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            require(b <= a, "SafeMath: subtraction overflow");
            return a - b;
        }

        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) return 0;
            uint256 c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow");
            return c;
        }

        function div(uint256 a, uint256 b) internal pure returns (uint256) {
            require(b > 0, "SafeMath: division by zero");
            return a / b;
        }
    }

    /**
     * @dev Constructor
     * @param _pyusdAddress The address of the PYUSD token contract
     */
    constructor(address _pyusdAddress) Ownable(msg.sender) {
        require(_pyusdAddress != address(0), "Invalid PYUSD address");
        pyusd = IPYUSD(_pyusdAddress);
    }

    /**
     * @dev Modifier to check if caller is authorized to pull payments
     */
    modifier onlyAuthorizedPuller() {
        require(authorizedPullers[msg.sender] || msg.sender == owner(), "Not authorized to pull payments");
        _;
    }

    // ==================== PLAN MANAGEMENT ====================

    /**
     * @dev Create a new subscription plan
     * @param name Plan name
     * @param price Price in PYUSD (with decimals, e.g., 1000000000000000000 for 1 PYUSD)
     * @param billingPeriod Billing period in seconds
     * @param maxSubscribers Maximum number of subscribers (0 for unlimited)
     */
    function createPlan(
        string memory name,
        uint256 price,
        uint256 billingPeriod,
        uint256 maxSubscribers
    ) external onlyOwner returns (uint256) {
        require(price > 0, "Price must be greater than 0");
        require(billingPeriod > 0, "Billing period must be greater than 0");

        uint256 planId = plans.length;
        plans.push(SubscriptionPlan({
            name: name,
            price: price,
            billingPeriod: billingPeriod,
            maxSubscribers: maxSubscribers,
            active: true,
            currentSubscribers: 0
        }));

        emit PlanCreated(planId, name, price, billingPeriod);
        return planId;
    }

    /**
     * @dev Update plan status (active/inactive)
     * @param planId Plan ID
     * @param active New status
     */
    function updatePlanStatus(uint256 planId, bool active) external onlyOwner {
        require(planId < plans.length, "Invalid plan ID");
        plans[planId].active = active;
        emit PlanUpdated(planId, active);
    }

    // ==================== SUBSCRIPTION MANAGEMENT ====================

    /**
     * @dev Subscribe to a plan using standard approve/transferFrom
     * @param planId Plan ID to subscribe to
     */
    function subscribe(uint256 planId) external nonReentrant whenNotPaused {
        require(planId < plans.length, "Invalid plan ID");
        SubscriptionPlan storage plan = plans[planId];
        require(plan.active, "Plan is not active");
        require(plan.maxSubscribers == 0 || plan.currentSubscribers < plan.maxSubscribers, "Plan is full");
        require(!subscriptions[msg.sender].active, "Already subscribed");

        // Check if user has approved enough tokens
        uint256 allowance = pyusd.allowance(msg.sender, address(this));
        require(allowance >= plan.price, "Insufficient allowance");

        // Transfer PYUSD from user to contract
        require(pyusd.transferFrom(msg.sender, address(this), plan.price), "Payment failed");

        // Update subscription
        UserSubscription storage userSub = subscriptions[msg.sender];
        userSub.planId = planId;
        userSub.startTime = block.timestamp;
        userSub.nextBillingDate = block.timestamp + plan.billingPeriod;
        userSub.active = true;
        userSub.totalPaid = plan.price;
        userSub.renewalCount = 0;

        plan.currentSubscribers++;

        emit Subscribed(msg.sender, planId, block.timestamp);
    }

    /**
     * @dev Subscribe using ERC20 Permit (gasless approval)
     * @param planId Plan ID
     * @param permitData Permit signature data (v, r, s)
     * @param deadline Permit deadline
     */
    function subscribeWithPermit(
        uint256 planId,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 deadline
    ) external nonReentrant whenNotPaused {
        require(planId < plans.length, "Invalid plan ID");
        SubscriptionPlan storage plan = plans[planId];
        require(plan.active, "Plan is not active");
        require(plan.maxSubscribers == 0 || plan.currentSubscribers < plan.maxSubscribers, "Plan is full");
        require(!subscriptions[msg.sender].active, "Already subscribed");

        // Execute permit
        pyusd.permit(msg.sender, address(this), plan.price, deadline, v, r, s);

        // Transfer tokens
        require(pyusd.transferFrom(msg.sender, address(this), plan.price), "Payment failed");

        // Update subscription
        UserSubscription storage userSub = subscriptions[msg.sender];
        userSub.planId = planId;
        userSub.startTime = block.timestamp;
        userSub.nextBillingDate = block.timestamp + plan.billingPeriod;
        userSub.active = true;
        userSub.totalPaid = plan.price;
        userSub.renewalCount = 0;

        plan.currentSubscribers++;

        emit Subscribed(msg.sender, planId, block.timestamp);
    }

    /**
     * @dev Process recurring payment (called by authorized puller or owner)
     * @param subscriber Address of subscriber
     */
    function processPayment(address subscriber) external nonReentrant onlyAuthorizedPuller {
        UserSubscription storage userSub = subscriptions[subscriber];
        require(userSub.active, "Subscription not active");
        require(block.timestamp >= userSub.nextBillingDate, "Billing date not reached");

        SubscriptionPlan storage plan = plans[userSub.planId];

        // Check allowance
        uint256 allowance = pyusd.allowance(subscriber, address(this));
        require(allowance >= plan.price, "Insufficient allowance");

        // Transfer payment
        require(pyusd.transferFrom(subscriber, address(this), plan.price), "Payment failed");

        // Update subscription
        userSub.nextBillingDate = userSub.nextBillingDate + plan.billingPeriod;
        userSub.totalPaid += plan.price;
        userSub.renewalCount++;

        emit PaymentProcessed(subscriber, userSub.planId, plan.price);
    }

    /**
     * @dev Cancel subscription
     */
    function cancelSubscription() external nonReentrant {
        UserSubscription storage userSub = subscriptions[msg.sender];
        require(userSub.active, "No active subscription");

        userSub.active = false;
        plans[userSub.planId].currentSubscribers--;

        emit SubscriptionCancelled(msg.sender);
    }

    /**
     * @dev Check if user is currently subscribed
     * @param user User address
     * @return isSubscribed True if user has active subscription
     */
    function isSubscribed(address user) external view returns (bool) {
        UserSubscription storage userSub = subscriptions[user];
        if (!userSub.active) return false;

        // Check if subscription is still valid (hasn't expired)
        if (block.timestamp > userSub.nextBillingDate) {
            return false;
        }

        return true;
    }

    /**
     * @dev Get user subscription details
     * @param user User address
     * @return planId Plan ID
     * @return startTime Subscription start time
     * @return nextBillingDate Next billing date
     * @return active Subscription status
     * @return totalPaid Total amount paid
     */
    function getUserSubscription(address user)
        external
        view
        returns (
            uint256 planId,
            uint256 startTime,
            uint256 nextBillingDate,
            bool active,
            uint256 totalPaid
        )
    {
        UserSubscription storage userSub = subscriptions[user];
        return (
            userSub.planId,
            userSub.startTime,
            userSub.nextBillingDate,
            userSub.active,
            userSub.totalPaid
        );
    }

    // ==================== ACCESS CONTROL & ADMIN ====================

    /**
     * @dev Authorize/unauthorize puller for automatic payments
     * @param puller Address to authorize
     * @param authorized Authorization status
     */
    function setPullerAuthorization(address puller, bool authorized) external onlyOwner {
        authorizedPullers[puller] = authorized;
        emit PullerAuthorized(puller, authorized);
    }

    /**
     * @dev Pause contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Emergency withdraw PYUSD tokens (owner only)
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(pyusd.transfer(owner(), amount), "Withdrawal failed");
    }

    /**
     * @dev Get plan details
     * @param planId Plan ID
     */
    function getPlan(uint256 planId)
        external
        view
        returns (
            string memory name,
            uint256 price,
            uint256 billingPeriod,
            uint256 maxSubscribers,
            bool active,
            uint256 currentSubscribers
        )
    {
        require(planId < plans.length, "Invalid plan ID");
        SubscriptionPlan storage plan = plans[planId];
        return (
            plan.name,
            plan.price,
            plan.billingPeriod,
            plan.maxSubscribers,
            plan.active,
            plan.currentSubscribers
        );
    }

    /**
     * @dev Get total number of plans
     */
    function getPlanCount() external view returns (uint256) {
        return plans.length;
    }

    /**
     * @dev Get contract balance (PYUSD)
     */
    function getContractBalance() external view returns (uint256) {
        return pyusd.balanceOf(address(this));
    }
}
