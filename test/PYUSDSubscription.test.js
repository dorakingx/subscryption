const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PYUSDSubscription", function () {
  let subscriptionContract;
  let pyusdToken;
  let owner;
  let user1;
  let user2;
  let puller;

  // PYUSD test addresses (these are mock addresses for testing)
  // In real deployment, use actual PYUSD testnet contract addresses
  const MOCK_PYUSD_ADDRESS = "0x0000000000000000000000000000000000000001";

  beforeEach(async function () {
    [owner, user1, user2, puller] = await ethers.getSigners();

    // Deploy contract with mock PYUSD address
    const Subscription = await ethers.getContractFactory("PYUSDSubscription");
    subscriptionContract = await Subscription.deploy(MOCK_PYUSD_ADDRESS);
    await subscriptionContract.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the correct PYUSD address", async function () {
      expect(await subscriptionContract.pyusd()).to.equal(MOCK_PYUSD_ADDRESS);
    });

    it("Should set the correct owner", async function () {
      expect(await subscriptionContract.owner()).to.equal(owner.address);
    });
  });

  describe("Plan Management", function () {
    it("Should create a new subscription plan", async function () {
      const tx = await subscriptionContract.createPlan(
        "Basic Plan",
        ethers.parseEther("10"), // 10 PYUSD
        2592000, // 30 days
        0 // unlimited
      );

      const receipt = await tx.wait();
      expect(receipt).to.not.be.null;
    });

    it("Should not create a plan with zero price", async function () {
      await expect(
        subscriptionContract.createPlan("Test", 0, 2592000, 0)
      ).to.be.revertedWith("Price must be greater than 0");
    });
  });

  describe("Subscription Management", function () {
    beforeEach(async function () {
      await subscriptionContract.createPlan(
        "Basic Plan",
        ethers.parseEther("10"),
        2592000,
        0
      );
    });

    it("Should check if user is subscribed", async function () {
      const isSubscribed = await subscriptionContract.isSubscribed(user1.address);
      expect(isSubscribed).to.be.false;
    });
  });

  describe("Access Control", function () {
    it("Should allow owner to pause the contract", async function () {
      await subscriptionContract.pause();
      expect(await subscriptionContract.paused()).to.be.true;
    });

    it("Should allow owner to authorize pullers", async function () {
      await subscriptionContract.setPullerAuthorization(puller.address, true);
      // Check emitted event or state
    });
  });
});
