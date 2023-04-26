import "hardhat";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Ballot", function() {
  async function deployContractFixture() {
    const [address] = await ethers.getSigners();
    const Ballot = await ethers.getContractFactory("Ballot");
    const ballot = await Ballot.deploy();
    return { ballot, address };
  }

  describe("Deployment", function() {
    this.timeout(5000);
    it("Contract does not have polls", async function() {
      const { ballot } = await loadFixture(deployContractFixture);
      expect(await ballot.getAllPolls()).to.be.empty;
    })
    it("Contract with no polls reverts getting results", async function() {
      const { ballot } = await loadFixture(deployContractFixture);
      await expect(ballot.getResults(0)).to.be.revertedWithPanic();
      await expect(ballot.getResults(3)).to.be.revertedWithPanic();
      await expect(ballot.getResults(333)).to.be.revertedWithPanic();
    })
  })
})