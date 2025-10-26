const hre = require("hardhat");

async function main() {
  console.log("Updating subscription plans to 1, 2, 3 PYUSD...");

  // Get the deployed contract address from environment or use the known address
  const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS || "0x3D8bE24704F15B7F290B986efced351f31e5B313";
  
  console.log("Contract address:", CONTRACT_ADDRESS);

  // Get the deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("Updating with account:", deployer.address);

  // Get contract instance
  const Subscription = await hre.ethers.getContractFactory("PYUSDSubscription");
  const subscription = await Subscription.attach(CONTRACT_ADDRESS);

  // Deactivate old plans
  console.log("\nDeactivating old plans...");
  try {
    await subscription.updatePlanStatus(0, false);
    await subscription.updatePlanStatus(1, false);
    await subscription.updatePlanStatus(2, false);
    console.log("Old plans deactivated");
  } catch (error) {
    console.log("Warning: Could not deactivate old plans:", error.message);
  }

  // Create new plans with 1, 2, 3 PYUSD
  console.log("\nCreating new plans with 1, 2, 3 PYUSD...");
  console.log("Note: PYUSD uses 6 decimals on testnet");
  
  // Plan 1: Basic - 1 PYUSD per month (PYUSD has 6 decimals, not 18)
  const tx1 = await subscription.createPlan(
    "Basic Plan",
    hre.ethers.parseUnits("1", 6), // 1 PYUSD with 6 decimals
    2592000, // 30 days in seconds
    0 // unlimited subscribers
  );
  await tx1.wait();
  console.log("✅ Created Basic Plan: 1 PYUSD/month");

  // Plan 2: Pro - 2 PYUSD per month
  const tx2 = await subscription.createPlan(
    "Pro Plan",
    hre.ethers.parseUnits("2", 6), // 2 PYUSD with 6 decimals
    2592000,
    0
  );
  await tx2.wait();
  console.log("✅ Created Pro Plan: 2 PYUSD/month");

  // Plan 3: Enterprise - 3 PYUSD per month
  const tx3 = await subscription.createPlan(
    "Enterprise Plan",
    hre.ethers.parseUnits("3", 6), // 3 PYUSD with 6 decimals
    2592000,
    0
  );
  await tx3.wait();
  console.log("✅ Created Enterprise Plan: 3 PYUSD/month");

  console.log("\n✅ Plans Updated Successfully!");
  console.log("==================");
  console.log("Contract Address:", CONTRACT_ADDRESS);
  console.log("Network:", hre.network.name);
  console.log("\nNew subscription plans:");
  console.log("- Basic Plan: 1 PYUSD/month");
  console.log("- Pro Plan: 2 PYUSD/month");
  console.log("- Enterprise Plan: 3 PYUSD/month");
  console.log("\nThe frontend will automatically load these new prices.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
