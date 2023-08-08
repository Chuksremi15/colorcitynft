import { expect } from "chai";
import { ethers } from "hardhat";
import { ColorCityNFT } from "../typechain-types";

describe("ColorCityNFT", function () {
  // We define a fixture to reuse the same setup in every test.

  let nftContract: ColorCityNFT;
  before(async () => {
    const [owner] = await ethers.getSigners();
    const nftContractFactory = await ethers.getContractFactory("ColorCityNFT");
    nftContract = (await nftContractFactory.deploy()) as ColorCityNFT;
    await nftContract.deployed();
  });

  describe("Deployment", function () {
    it("Should mint successfully", async function () {
      const [owner] = await ethers.getSigners();

      await nftContract.mintItem();

      expect(await nftContract.balanceOf(owner.address)).to.greaterThanOrEqual(1);
    });

    it("Should fetch user token balance", async function () {
      const [owner] = await ethers.getSigners();

      const tokenIdBeforeMint = await nftContract.tokenOfOwnerByIndex(owner.address, 0);

      console.log("address token index before mint", tokenIdBeforeMint.toString());

      const mintResult = await nftContract.mintItem();

      console.log("\t", " 🏷  mint tx: ", mintResult.hash);

      console.log("\t", " ⏳ Waiting for confirmation...");
      const txResult = await mintResult.wait();
      expect(txResult.status).to.equal(1);

      const tokenIdAfterMint = await nftContract.tokenOfOwnerByIndex(owner.address, 1);

      console.log("address token index after mint", tokenIdAfterMint.toString());
    });
  });
});
