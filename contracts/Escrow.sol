//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import './CloneFactory.sol';
contract EscrowFactory is CloneFactory {
     Escrow[] public children;
     address masterContract;

     constructor(address _masterContract){
         masterContract = _masterContract;
     }

     function createChild(address payable owner) external{
        Escrow child = Escrow(createClone(masterContract));
        child.initUserA(owner);
        children.push(child);
     }

     function getChildren() external view returns(Escrow[] memory){
         return children;
     }
 
    
}

contract Helpers {
    function getbalance() public view returns(uint256){
        return address(this).balance;
    }
}
contract Escrow is Helpers{
    enum Workflow { WAITING_FOR_FUND, AWAITING_WORK_TOBE_COMPLETED , WORK_COMPLETED }
    
    Workflow public currWorkflow;
    
    address payable public  user_A;
    address payable public user_B;
    

    function initUserA(address payable _user_A) external{
        user_A = _user_A;
    }
    
    function depositAndAssign(address payable _user_B) external payable {
        require(msg.sender == user_A,"only user_A can fund");
        user_B = _user_B;
        require(currWorkflow == Workflow.WAITING_FOR_FUND, "Already paid");
        currWorkflow = Workflow.AWAITING_WORK_TOBE_COMPLETED;
    }
    
    function confirmWorkDone() external {
        require(msg.sender == user_B,"only user_B can confirm the work");
        require(currWorkflow == Workflow.AWAITING_WORK_TOBE_COMPLETED, "Work yet to be assigned");
        currWorkflow = Workflow.WORK_COMPLETED;
    }
    
    function confirmAndPay() external payable{
        require(msg.sender == user_A,"only user_A can confirm the work");
        require(currWorkflow == Workflow.WORK_COMPLETED,"Work yet to be completed");
        user_B.transfer(address(this).balance);
    }
}