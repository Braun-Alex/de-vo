// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

contract Ballot {
    struct Poll {
        string title;
        string question;
        string[] proposals;
        address author;
        uint256 whenCreated;
        uint duration;
    }

    Poll[] allPolls;

    uint[][] votesPerPoll;

    mapping(address => uint[]) pollsPerAddress;

    mapping(address => mapping(uint => bool)) hasVoted;

    event Create(address indexed _from, uint _timestamp, Poll _poll);

    event Vote(address indexed _from, uint _timestamp, string _proposal);

    function create(string memory _title, string memory _question, 
    string[] memory _proposals, uint _duration) public {
        address _author = msg.sender;
        uint _whenCreated = block.timestamp;
        uint pollId = allPolls.length;
        pollsPerAddress[_author].push(pollId);
        votesPerPoll.push();
        for (uint i = 0; i < _proposals.length; i++) {
            votesPerPoll[pollId].push();
        }
        allPolls.push(Poll(
            _title, 
            _question, 
            _proposals, 
            _author, 
            _whenCreated, 
            _duration));
        emit Create(_author, _whenCreated, allPolls[pollId]);
    }

    function vote(uint _pollId, string memory _pollProposal) public {
        Poll memory poll = allPolls[_pollId];
        uint currentTimestamp = block.timestamp;
        require(currentTimestamp >= poll.whenCreated + poll.duration, "Poll has been finished!");
        address voter = msg.sender;
        require(!hasVoted[voter][_pollId], "Voter has already voted");
        string[] memory proposals = poll.proposals;
        bool doesExistProposal = false;
        for (uint i = 0; i < proposals.length; i++) {
            if (keccak256(abi.encodePacked(proposals[i])) == 
            keccak256(abi.encodePacked(_pollProposal))) {
                doesExistProposal = true;
                votesPerPoll[_pollId][i] += 1;
            }
        }
        require(doesExistProposal, "Such proposal does not exist");
        hasVoted[voter][_pollId] = true;
        emit Vote(voter, currentTimestamp, _pollProposal);
    }

    function getPoll(uint _pollId) public view returns (Poll memory) {
        return allPolls[_pollId];
    }

    function getAllPolls() public view returns (Poll[] memory) {
        return allPolls;
    }

    function getTotalPolls() public view returns (uint) {
        return allPolls.length;
    }

    function getWinningProposal(uint _pollId) public view returns (string memory) {
        Poll memory poll = allPolls[_pollId];
        require(!(block.timestamp >= poll.whenCreated + poll.duration), "Poll has not been finished yet!");
        uint[] memory votes = votesPerPoll[_pollId];
        uint winningProposalIndex = 0;
        uint maxCount = 0;
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i] > maxCount) {
                maxCount = votes[i];
                winningProposalIndex = i;
            }
        }
        return allPolls[_pollId].proposals[winningProposalIndex];
    }
}