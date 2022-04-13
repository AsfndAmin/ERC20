const hre = require("hardhat");

let escrow;
let stakePool;
let lpPool;
const CTZN = "0xA803778AB953d3FfE4FBD20Cfa0042eCeFE8319D";
const LP = "0x39978CE682269dED83566d23de86b4410eeF3B2C";
const owner = "0x6934b7875fEABE4FA129D4988ca6DEcD1Dca9C2B";
const oneYear = "31536000";
const zeroAddress = "0x0000000000000000000000000000000000000000";

async function escrowPool() {
  try {
    let contract = await ethers.getContractFactory(
      "TimeLockNonTransferablePool"
    );
    console.log("Deploying contract first...");

    escrow = await contract.deploy(
      "Escrow CTZN",
      "ECTZN",
      CTZN,
      CTZN,
      zeroAddress,
      0,
      0,
      0,
      oneYear
    );
    // await escrow.deployed();

    console.log("escrow deployed to:", escrow.address);
  } catch (error) {
    console.log("error", error);
  }
}

async function CTZNPool() {
  try {
    let escrowAddress = `"${escrow.address}"`;
    if (escrowAddress) {
      console.log("aaaaaaaaa:");
      var contract = await ethers.getContractFactory(
        "TimeLockNonTransferablePool"
      );
      stakePool = await contract.deploy(
        "Staked CTZN",
        "SCTZN",
        CTZN,
        CTZN,
        escrow.address,
        "1000000000000000000",
        oneYear,
        "1000000000000000000",
        oneYear
      );

      console.log("stakePool deployed to:", stakePool.address);

      console.log("Assigning REWARD_DISTRIBUTOR_ROLE for CTZN Stake Pool");
      const CTZN_REWARD_DISTRIBUTOR_ROLE =
        await stakePool.REWARD_DISTRIBUTOR_ROLE();
      console.log("before CRD");
      await stakePool.grantRole(CTZN_REWARD_DISTRIBUTOR_ROLE, owner);
      console.log("after CRD");
    }
  } catch (error) {
    console.log("error at 2:", error);
  }
}

async function CTZNLPPool() {
  try {
    let escrowAddress = `"${escrow.address}"`;
    if (escrowAddress) {
      var contract = await ethers.getContractFactory(
        "TimeLockNonTransferablePool"
      );

      lpPool = await contract.deploy(
        "CTZN/BUSD CAKE-LP",
        "SCTZNLP",
        LP,
        CTZN,
        escrow.address,
        "1000000000000000000",
        oneYear,
        "1000000000000000000",
        oneYear
      );

      console.log("lpPool deployed to:", lpPool.address);

      console.log("Assigning REWARD_DISTRIBUTOR_ROLE for CTZN LP Pool");
      const LP_REWARD_DISTRIBUTOR_ROLE = await lpPool.REWARD_DISTRIBUTOR_ROLE();
      await lpPool.grantRole(LP_REWARD_DISTRIBUTOR_ROLE, owner);
    }
  } catch (error) {
    console.log("error at 2:", error);
  }
}

async function View() {
  try {
    let escrowAddress = `"${escrow.address}"`;
    if (escrowAddress) {
      var contract = await ethers.getContractFactory("View");

      const view = await contract.deploy(
        [stakePool.address, lpPool.address],
        escrow.address
      );

      // await view.deployed();
      console.log("view deployed to:", view.address);
    }
  } catch (error) {}
}

async function main() {
  try {
    await escrowPool();
    await CTZNPool();
    await CTZNLPPool();
    await View();
  } catch (error) {
    console.log("main: ", error);
  }
}

main();
