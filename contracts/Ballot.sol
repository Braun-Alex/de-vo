// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

contract Ballot {
    constructor() {}

    uint256 totalPolls;

    struct Poll {
        string title;
        string question;
        string[] options;
        address author;
        uint256 whenCreated;
    }
    
    mapping(uint => Poll) pollPerId;

    mapping(address => uint[]) pollsPerAddress;

    mapping(uint => mapping(string => uint)) votesPerPoll;

    function createPoll (string memory _title, string memory _question, 
    string[] memory _options) public {
        address _author = msg.sender;
        uint _whenCreated = block.timestamp;
        string memory _optionsData;
        for (uint i = 0; i < _options.length; i++) {
            string.concat(bytes(_optionsData), bytes(_options[i]));
        }
        uint randomHash = uint(keccak256(abi.encodePacked(keccak256(abi.encodePacked(
            _title,
            _question,
            _optionsData,
            _author,
            _whenCreated
        )))));
        pollPerId[randomHash] = Poll(_title, _question, _options, _author, _whenCreated);
        pollsPerAddress[_author].push(randomHash);
    }
}