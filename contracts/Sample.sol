// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// NOTE: Deploy this contract first
contract Beta {
    // NOTE: storage layout must be the same as contract A
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) public payable returns (uint) {
        num = _num;
        sender = msg.sender;
        value = msg.value;
        return num;
    }
}

contract Alpha{
    uint public num;
    address public sender;
    uint public value;
 
    function setVars(address _contract, uint _num) public payable returns(uint){
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
         
        return abi.decode(data,(uint256));

    }
}