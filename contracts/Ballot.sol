// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

contract Ballot {
    constructor() {}

    uint256 totalBallots;

    struct Poll {
        string title;
        string question;
        string[] options;
        mapping(string => uint64) votes;
        address author;
        uint256 whenCreated;
    }
    
    mapping(uint256 => Ballot) pollPerId;

    mapping(address => uint256[]) pollsPerAddress;

    function createPoll (string memory _title, string memory _question, 
    string[] memory _options) public {
    }
}