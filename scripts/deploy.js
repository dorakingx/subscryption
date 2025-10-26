const hre = require("hardhat");

async function main() {
  console.log("Deploying PYUSDSubscription contract...");

  // Get the deployment account
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await hre.ethers.provider.getBalance(deployer.address)).toString());

  // PYUSD testnet address - update this with actual PYUSD testnet address
  const PYUSD_ADDRESS = process.env.PYUSD_ADDRESS || "0x0000000000000000000000000000000000000000";
  
  if (PYUSD_ADDRESS === "0x0000000000000000000000000000000000000000") {
    console.error("Error: PYUSD_ADDRESS not set in environment variables");
    console.error("Please set PYUSD_ADDRESS in your .env file");
    process.exit(1);
  }

  console.log("Using PYUSD address:", PYUSD_ADDRESS);

  // Deploy contract
  const Subscription = await hre.ethers.getContractFactory("PYUSDSubscription");
  const subscription = await Subscription.deploy(PYUSD_ADDRESS);

  await subscription.waitForDeployment();
  const address = await subscription.getAddress();

  console.log("Subscription contract deployed to:", address);

  // Wait for block confirmations
  if (hre.network.name !== "hardhat") {
    console.log("Waiting for block confirmations...");
    await subscription.deploymentTransaction()?.wait(5);
  }

  // Verify contract on block explorer (if not on hardhat network)
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("Verifying contract on block explorer...");
    try {
      await hre.run("verify:verify", {
        address: address,
        constructorArguments: [PYUSD_ADDRESS],
      });
    } catch (error) {
      if (error.message.includes("Already Verified")) {
        console.log("Contract already verified");
      } else {
        console.log("Error verifying contract:", error.message);
      }
    }
  }

  // Create some default plans
  console.log("\nCreating default subscription plans...");
  console.log("Note: PYUSD uses 6 decimals on testnet");
  
  // Plan 1: Basic - 1 PYUSD per month (PYUSD has 6 decimals, not 18)
  const tx1 = await subscription.createPlan(
    "Basic Plan",
    hre.ethers.parseUnits("1", 6), // 1 PYUSD with 6 decimals
    2592000, // 30 days in seconds
    0 // unlimited subscribers
  );
  await tx1.wait();
  console.log("Created Basic Plan");

  // Plan 2: Pro - 2 PYUSD per month
  const tx2 = await subscription.createPlan(
    "Pro Plan",
    hre.ethers.parseUnits("2", 6), // 2 PYUSD with 6 decimals
    2592000,
    0
  );
  await tx2.wait();
  console.log("Created Pro Plan");

  // Plan 3: Enterprise - 3 PYUSD per month
  const tx3 = await subscription.createPlan(
    "Enterprise Plan",
    hre.ethers.parseUnits("3", 6), // 3 PYUSD with 6 decimals
    2592000,
    0
  );
  await tx3.wait();
  console.log("Created Enterprise Plan");

  console.log("\nDeployment Summary:");
  console.log("==================");
  console.log("Contract Address:", address);
  console.log("Network:", hre.network.name);
  console.log("PYUSD Token:", PYUSD_ADDRESS);
  console.log("\nCreated 3 subscription plans:");
  console.log("- Basic Plan: 1 PYUSD/month");
  console.log("- Pro Plan: 2 PYUSD/month");
  console.log("- Enterprise Plan: 3 PYUSD/month");
  console.log("\nUpdate your frontend .env.local with:");
  console.log(`NEXT_PUBLIC_CONTRACT_ADDRESS=${address}`);
  console.log(`NEXT_PUBLIC_PYUSD_ADDRESS=${PYUSD_ADDRESS}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
