pragma solidity ^0.8.0;

import  "./FlashLoanReceiverBase.sol";
// import { ILendingPool,ILendingPoolAddressesProvider } from "./Interfaces.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract TestFlashLoan is FlashLoanReceiverBase {
  using SafeMath for uint;
  uint multiples;
  event Log(string message, uint val);

  constructor(ILendingPoolAddressesProvider _addressProvider)
    public
    FlashLoanReceiverBase(_addressProvider)
  {}

  function testFlashLoan(address asset, uint amount,uint _multiples) external {
    // uint bal = IERC20(asset).balanceOf(address(this));
    // require(bal > amount, "bal <= amount");
    multiples = _multiples;
    uint256 amountToLoan = (amount * multiples)/100;
    address receiver = address(this);

    address[] memory assets = new address[](1);
    assets[0] = asset;

    uint[] memory amounts = new uint[](1);
    amounts[0] = amountToLoan;

    // 0 = no debt, 1 = stable, 2 = variable
    // 0 = pay all loaned
    uint[] memory modes = new uint[](1);
    modes[0] = 0;

    address onBehalfOf = address(this);

    bytes memory params = ""; // extra data to pass abi.encode(...)
    uint16 referralCode = 0;

    LENDING_POOL.flashLoan(
      receiver,
      assets,
      amounts,
      modes,
      onBehalfOf,
      params,
      referralCode
    );
  }

  function executeOperation(
    address[] calldata assets,
    uint[] calldata amounts,
    uint[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external override returns (bool) {

    
   
    for (uint i = 0; i < assets.length; i++) {
      emit Log("borrowed", amounts[i]);
      emit Log("fee", premiums[i]);

      uint amountOwing = amounts[i].add(premiums[i]);
      IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
    }
    // repay Aave
    return true;
  }
}