pragma solidity ^0.8.1;

import  "./FlashLoanReceiverBase.sol";
import { IUniswapV2Router } from "./Interfaces.sol";

contract TestFlashLoan is FlashLoanReceiverBase {
  using SafeMath for uint;
  ILendingPoolAddressesProvider provider;
  uint multiples;
  event Log(string message, uint val);
  address lendingPoolAddr;
  address borrowAsset;
  uint16 interestMode;
  address constant UNISWAP_V2_ROUTER  = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

  constructor(ILendingPoolAddressesProvider _addressProvider)
    public
    FlashLoanReceiverBase(_addressProvider)
  {
        provider = _addressProvider;
        lendingPoolAddr = provider.getLendingPool();
  }

  function testFlashLoan(address asset, uint amount,uint _multiples,address _borrowAsset,uint16 _interestMode) external {
    // uint bal = IERC20(asset).balanceOf(address(this));
    // require(bal > amount, "bal <= amount");
    multiples = _multiples;
    borrowAsset=_borrowAsset;
    interestMode = _interestMode;
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

  address[] memory path;
  
   ILendingPool lendingPool = ILendingPool(lendingPoolAddr);
   IERC20(assets[0]).approve(lendingPoolAddr, amounts[0]);
   lendingPool.deposit(assets[0],amounts[0],address(this),0);
   uint256 amountToBorrow = ((amounts[0]*60)/100);
   lendingPool.borrow(borrowAsset,amountToBorrow,interestMode,0,address(this));
   uint256 minAmount = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(amountToBorrow,[borrowAsset,assets[0]]);
   IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            amountToBorrow,
            minAmount,
            [borrowAsset,assets[0]],
            address(this),
            block.timestamp
        );
   
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