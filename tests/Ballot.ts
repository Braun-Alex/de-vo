import { expect } from "chai";
import hre from "hardhat";

async function deployContract(contractName: string) {
    // @ts-ignore
    const Contract = await hre.ethers.getContractFactory(contractName);
    return await Contract.deploy();
}

describe("Initializing of contract", function () {
    it("Tests", async function () {
        expect(3).to.equal(3);
    });
});