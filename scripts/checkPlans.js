const hre = require("hardhat");

async function main() {
  console.log("Checking current subscription plans...");

  const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS || "0x3D8bE24704F15B7F290B986efced351f31e5B313";
  
  console.log("Contract address:", CONTRACT_ADDRESS);

  const [deployer] = await hre.ethers.getSigners();
  console.log("Reading with account:", deployer.address);

  const Subscription = await hre.ethers.getContractFactory("PYUSDSubscription");
  const subscription = await Subscription.attach(CONTRACT_ADDRESS);

  // Get plan count
  const planCount = await subscription.getPlanCount();
  console.log(`\nTotal plans: ${planCount}`);

  // List all plans
  for (let i = 0; i < planCount; i++) {
    const plan = await subscription.getPlan(i);
    console.log(`\nPlan ${i}:`);
    console.log(`  Name: ${plan.name}`);
    console.log(`  Price: ${hre.ethers.formatEther(plan.price)} PYUSD`);
    console.log(`  Active: ${plan.active}`);
    console.log(`  Subscribers: ${plan.currentSubscribers}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
