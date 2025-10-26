// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./IPYUSD.sol";

/**
 * @title PYUSDSubscription
 * @dev Smart contract for managing PYUSD-based subscription services
 * @notice Supports programmable payment logic, multiple subscription plans, and automatic renewals
 */
contract PYUSDSubscription is Ownable, ReentrancyGuard, Pausable {
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
    
    // Additional events for better tracking
    event AllowanceInsufficient(address indexed subscriber, uint256 required, uint256 current);
    event PermitDeadlineExceeded(address indexed subscriber, uint256 deadline);
    event EmergencyWithdrawal(address indexed recipient, uint256 amount);

    /**
     * @dev Constructor
     * @param _pyusdAddress The address of the PYUSD token contract
     */
    constructor(address _pyusdAddress) Ownable(msg.sender) {
        require(_pyusdAddress != address(0), "PYUSD address cannot be zero");
        pyusd = IPYUSD(_pyusdAddress);
    }

    /**
     * @dev Modifier to check if caller is authorized to pull payments
     */
    modifier onlyAuthorizedPuller() {
        require(authorizedPullers[msg.sender] || msg.sender == owner(), "Unauthorized: only authorized pullers can execute");
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
        require(price > 0, "Plan price must be greater than zero");
        require(billingPeriod > 0, "Billing period must be greater than zero");

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
        require(planId < plans.length, "Invalid plan ID: plan does not exist");
        plans[planId].active = active;
        emit PlanUpdated(planId, active);
    }

    // ==================== SUBSCRIPTION MANAGEMENT ====================

    /**
     * @dev Subscribe to a plan using standard approve/transferFrom
     * @param planId Plan ID to subscribe to
     */
    function subscribe(uint256 planId) external nonReentrant whenNotPaused {
        require(planId < plans.length, "Invalid plan ID: plan does not exist");
        SubscriptionPlan storage plan = plans[planId];
        require(plan.active, "Plan is currently inactive");
        require(plan.maxSubscribers == 0 || plan.currentSubscribers < plan.maxSubscribers, "Plan has reached maximum subscribers");
        require(!subscriptions[msg.sender].active, "User already has an active subscription");

        // Check if user has approved enough tokens
        uint256 allowance = pyusd.allowance(msg.sender, address(this));
        require(allowance >= plan.price, "Insufficient PYUSD allowance for payment");

        // Transfer PYUSD from user to contract
        bool transferSuccess = pyusd.transferFrom(msg.sender, address(this), plan.price);
        require(transferSuccess, "PYUSD transfer failed");

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
     * @param v Permit signature v component
     * @param r Permit signature r component
     * @param s Permit signature s component
     * @param deadline Permit deadline
     */
    function subscribeWithPermit(
        uint256 planId,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 deadline
    ) external nonReentrant whenNotPaused {
        require(planId < plans.length, "Invalid plan ID: plan does not exist");
        require(block.timestamp <= deadline, "Permit deadline has expired");
        
        SubscriptionPlan storage plan = plans[planId];
        require(plan.active, "Plan is currently inactive");
        require(plan.maxSubscribers == 0 || plan.currentSubscribers < plan.maxSubscribers, "Plan has reached maximum subscribers");
        require(!subscriptions[msg.sender].active, "User already has an active subscription");

        // Execute permit
        pyusd.permit(msg.sender, address(this), plan.price, deadline, v, r, s);

        // Transfer tokens
        bool transferSuccess = pyusd.transferFrom(msg.sender, address(this), plan.price);
        require(transferSuccess, "PYUSD transfer failed after permit");

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
        require(userSub.active, "Subscription is not active");
        require(block.timestamp >= userSub.nextBillingDate, "Billing date not yet reached");

        SubscriptionPlan storage plan = plans[userSub.planId];

        // Check allowance
        uint256 allowance = pyusd.allowance(subscriber, address(this));
        require(allowance >= plan.price, "Insufficient PYUSD allowance for recurring payment");

        // Transfer payment
        bool transferSuccess = pyusd.transferFrom(subscriber, address(this), plan.price);
        require(transferSuccess, "PYUSD transfer failed during payment processing");

        // Update subscription
        userSub.nextBillingDate += plan.billingPeriod;
        userSub.totalPaid += plan.price;
        userSub.renewalCount++;

        emit PaymentProcessed(subscriber, userSub.planId, plan.price);
    }

    /**
     * @dev Cancel subscription with refund if within 24 hours
     * @notice Refunds are only available if subscription is cancelled within 24 hours of start time
     */
    function cancelSubscription() external nonReentrant {
        UserSubscription storage userSub = subscriptions[msg.sender];
        require(userSub.active, "No active subscription found to cancel");

        SubscriptionPlan storage plan = plans[userSub.planId];
        uint256 refundAmount = 0;
        bool isRefundable = false;

        // Check if subscription started within last 24 hours
        if (block.timestamp <= userSub.startTime + 1 days) {
            isRefundable = true;
            refundAmount = plan.price;
        }

        // Deactivate subscription
        userSub.active = false;
        plans[userSub.planId].currentSubscribers--;

        // Process refund if eligible
        if (isRefundable && refundAmount > 0) {
            bool transferSuccess = pyusd.transfer(msg.sender, refundAmount);
            require(transferSuccess, "Refund transfer failed");
            emit RefundProcessed(msg.sender, refundAmount);
        }

        emit SubscriptionCancelled(msg.sender);
    }

    /**
     * @dev Check if user is currently subscribed
     * @param user User address
     * @return isSubscribed True if user has active subscription
     * 
     * Note: This function does not automatically update expired subscriptions.
     * Consider calling updateExpiredSubscription() separately if state updates are needed.
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
     * @dev Update expired subscription status
     * @notice This function can be called by anyone to update the status of expired subscriptions
     */
    function updateExpiredSubscription(address user) external {
        UserSubscription storage userSub = subscriptions[user];
        if (userSub.active && block.timestamp > userSub.nextBillingDate) {
            userSub.active = false;
            plans[userSub.planId].currentSubscribers--;
            emit SubscriptionExpired(user, userSub.planId);
        }
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
        require(puller != address(0), "Puller address cannot be zero");
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
     * 
     * Security recommendations:
     * - Consider implementing a time-lock mechanism for large withdrawals
     * - Consider implementing maximum withdrawal limits per transaction
     * - Consider requiring multiple owner signatures for large withdrawals
     * - Consider splitting withdrawals into multiple smaller transactions
     * - Consider implementing an emergency pause before withdrawals
     * 
     * Example implementation for time-lock:
     * - Store withdrawal requests in a mapping with timestamps
     * - Require a waiting period (e.g., 24-48 hours) before withdrawal
     * - Allow cancellation during the waiting period
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        uint256 contractBalance = pyusd.balanceOf(address(this));
        require(amount <= contractBalance, "Withdrawal amount exceeds contract balance");
        require(amount > 0, "Withdrawal amount must be greater than zero");
        
        bool transferSuccess = pyusd.transfer(owner(), amount);
        require(transferSuccess, "Withdrawal transfer failed");
        
        emit EmergencyWithdrawal(owner(), amount);
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
        require(planId < plans.length, "Invalid plan ID: plan does not exist");
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
