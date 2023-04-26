import "hardhat";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

interface Poll {
  title: string,
  question: string,
  proposals: string[],
  duration: number
}

describe("Ballot", function() {
  async function deployContractFixture() {
    const [address] = await ethers.getSigners();
    const Ballot = await ethers.getContractFactory("Ballot");
    const ballot = await Ballot.deploy();
    return { ballot, address };
  }

  describe("Deployment", function() {
    it("Contract does not have polls", async function() {
      this.timeout(5000);
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

  describe("Creating", function() {
    const emptyPolls: Poll[] = [
      {
        title: "Orange",
        question: "What will you choose if there is no proposals?",
        proposals: [],
        duration: 1000 * 60 * 60 * 24
      },
      {
        title: "Choice always exists",
        question: "What is better: banana or orange?",
        proposals: [],
        duration: 1000 * 60 * 60
      },
      {
        title: "Title",
        question: "Question?",
        proposals: [],
        duration: 1000 * 60
      }
    ]

    emptyPolls.forEach((emptyPoll: Poll) => {
      it(`Contract reverts creating of poll "${emptyPoll.title}" with no proposals`,
          async function () {
        const { ballot } = await loadFixture(deployContractFixture);
        await expect(ballot.create(emptyPoll.title, emptyPoll.question,
            emptyPoll.proposals, emptyPoll.duration)
        ).to.be.revertedWith("Count of proposals must be greater than one!");
      })
    })

    const pollsWithoutChoice: Poll[] = [
      {
        title: "No choice",
        question: "What will you choose if there is no choice?",
        proposals: ["Choice"],
        duration: 1000 * 60 * 60 * 24
      },
      {
        title: "Choice always exists",
        question: "What is better: banana or orange?",
        proposals: ["Orange"],
        duration: 1000 * 60 * 60
      },
      {
        title: "Title",
        question: "Question?",
        proposals: ["Ring signature"],
        duration: 1000 * 60
      }
    ]

    pollsWithoutChoice.forEach((pollWithoutChoice: Poll) => {
      it(`Contract reverts creating of poll "${pollWithoutChoice.title}" with one proposal`,
          async function () {
            const { ballot } = await loadFixture(deployContractFixture);
            await expect(ballot.create(pollWithoutChoice.title, pollWithoutChoice.question,
                pollWithoutChoice.proposals, pollWithoutChoice.duration)
            ).to.be.revertedWith("Count of proposals must be greater than one!");
          })
    })

    const poll: Poll = {
      title: "Choosing of cryptographic method",
      question: "Which of cryptographic methods is better for using in decentralized voting?",
      proposals: ["Homomorphic encryption", "Zero knowledge proofs", "Ring signatures"],
      duration: 1000 * 60 * 60 * 24
    }

    it("Contract successfully creates poll on-chain", async function() {
      const { ballot } = await loadFixture(deployContractFixture);
      ballot.create(poll.title, poll.question, poll.proposals, poll.duration).then(
          (callback) => {
            expect(callback).to.emit(ballot, "Create");
            expect(callback).not.to.be.reverted;
            ballot.getResults(0).then((contractPoll) => {
              contractPoll.not.to.be.reverted;
              expect(contractPoll.title).to.equal(poll.title);
              expect(contractPoll.question).to.equal(poll.question);
              expect(contractPoll.proposals).to.equal(poll.proposals);
              expect(contractPoll.duration).to.equal(poll.duration);
              ballot.getAllPolls().then((allPolls) => {
                expect(allPolls[0]).to.equal(contractPoll);
              })
            })
          }
      )
    })
  })
})