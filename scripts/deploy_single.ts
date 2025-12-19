import { ethers } from "hardhat";
import * as dotenv from "dotenv";
import * as fs from "fs";
import * as path from "path";

dotenv.config();

async function main() {
  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying with account:", deployer.address);
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH");
  
  const ContractFactory = await ethers.getContractFactory("PharmacyCore");
  const contract = await ContractFactory.deploy();
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  
  console.log("PharmacyCore deployed to:", address);
  
  // Save to contracts.json
  const contractsPath = path.join(__dirname, "..", "contracts.json");
  let contracts: Record<string, string> = {};
  if (fs.existsSync(contractsPath)) {
    contracts = JSON.parse(fs.readFileSync(contractsPath, "utf-8"));
  }
  contracts["PharmacyCore"] = address;
  fs.writeFileSync(contractsPath, JSON.stringify(contracts, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
