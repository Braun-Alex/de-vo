// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

contract Ballot {
    constructor() {}

    uint256 totalPolls;

    struct Poll {
        string title;
        string question;
        string[] proposals;
        address author;
        uint256 whenCreated;
        uint duration;
    }
    
    mapping(uint => Poll) pollPerId;

    mapping(address => uint[]) pollsPerAddress;

    mapping(uint => uint[]) votesPerPoll;

    mapping(uint => address[]) castedVotes;

    function createPoll (string memory _title, string memory _question, 
    string[] memory _proposals, uint _duration) public {
        totalPolls += 1;
        address _author = msg.sender;
        uint _whenCreated = block.timestamp;
        string memory _proposalsData;
        for (uint i = 0; i < _proposals.length; i++) {
            string.concat(bytes(_proposalsData), bytes(_proposals[i]));
        }
        uint randomHash = uint(keccak256(abi.encodePacked(keccak256(abi.encodePacked(
            _title,
            _question,
            _proposalsData,
            _author,
            _whenCreated,
            _duration
        )))));
        pollPerId[randomHash] = Poll(
            _title, 
            _question, 
            _proposals, 
            _author, 
            _whenCreated, 
            _duration);
        pollsPerAddress[_author].push(randomHash);
        for (uint i = 0; i < _proposals.length; i++) {
            votesPerPoll[randomHash].push(0);
        }
    }

    function getInfo(uint _id) public view returns (Poll memory) {
        return pollPerId[_id];
    }

    function getWinningProposal(uint _pollId) public view returns (string memory) {
        Poll memory poll = pollPerId[_pollId];
        require(!(block.timestamp >= poll.whenCreated + poll.duration), "Poll has not been finished!");
        uint[] memory votes = votesPerPoll[_pollId];
        uint winningProposalIndex = 0;
        uint maxCount = 0;
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i] > maxCount) {
                maxCount = votes[i];
                winningProposalIndex = i;
            }
        }
        return pollPerId[_pollId].proposals[winningProposalIndex];
    }

    function vote(uint _pollId, string memory _pollOption) public {
        Poll memory poll = pollPerId[_pollId];
        require(block.timestamp >= poll.whenCreated + poll.duration, "Poll has been finished!");
        address[] memory votes = castedVotes[_pollId];
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i] == msg.sender) {
                revert("Voter has already voted");
            }
        }
        string[] memory proposals = poll.proposals;
        bool doesExistProposal = false;
        for (uint i = 0; i < proposals.length; i++) {
            if (keccak256(abi.encodePacked(proposals[i])) == 
            keccak256(abi.encodePacked(_pollOption))) {
                doesExistProposal = true;
                votesPerPoll[_pollId][i] += 1;
            }
        }
        require(doesExistProposal, "Such proposal does not exist");
        castedVotes[_pollId].push(msg.sender);
    }
}