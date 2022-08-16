pragma solidity ^0.8.4;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract ClaimMoneyV1 is ERC20, Ownable {

    uint256 public amount;
    uint public sample;
 constructor() ERC20("SampleToken", "SMTK") {}

    function mint(address to, uint256 _amount) public {
        _mint(to, _amount);
    }
    function calimMoney()  public payable  {
       mint(msg.sender,1000);
    }

    
    
}