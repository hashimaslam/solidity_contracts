pragma solidity 0.8.0;


import {ILendingPool,IProtocolDataProvider,ILendingPoolAddressesProvider} from "interfaces.sol";
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol';

contract Leverage{
    ILendingPoolAddressesProvider provider;
    ILendingPool lPool;
    IProtocolDataProvider constant dataProvider = IProtocolDataProvider(address(0x3c73A5E5785cAC854D468F727c606C07488a29D6));
    IERC20 token;
    address owner;
    address pool;
    uint256 lastAmount;

    constructor(address _provider)  public {
       provider = ILendingPoolAddressesProvider(_provider);
       address lp = provider.getLendingPool();
       pool = lp;
       lPool = ILendingPool(address(lp));
       owner = msg.sender;
   }

   function getAtokenBal(address asset) external view returns(uint256){
       (address aTokenAddress,,) = dataProvider.getReserveTokensAddresses(asset);
        uint256 aTokenBalance =  IERC20(aTokenAddress).balanceOf(address(this));
        return aTokenBalance;
   }
    function depositToPool(address asset,uint256 amount) external   {
        IERC20 token =  IERC20(address(asset));
        token.approve(address(pool),amount);
         lPool.deposit(asset,amount,address(this),0);
      
   }

    function doLeverage(address asset,uint256 amount,uint16 times,uint256 cf,uint256 interestRateMode) external returns(uint256){
        //uint256 _amount = (amount * cf)/100;
         lastAmount = amount;
         uint256 leveragedAmnt = (amount * times)/100;
         IERC20(asset).approve(address(pool),leveragedAmnt);
         lPool.deposit(asset,amount,address(this),0);
         (address aTokenAddress,,) = dataProvider.getReserveTokensAddresses(asset);
         
         for(uint i = 1 ; i>0; i++  ){
             uint256 aTokenBalance =  IERC20(aTokenAddress).balanceOf(address(this));
             if(aTokenBalance >= leveragedAmnt){
                 break;
             }
             uint256 amountToBorrow = ((lastAmount * cf)/100)/100;
             lPool.borrow(asset, amountToBorrow,interestRateMode,0, address(this));
             lPool.deposit(asset,amountToBorrow,address(this),0);
             lastAmount = amountToBorrow;
         }
        
    }



}