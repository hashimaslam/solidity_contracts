
import "ierc20.sol";
import "lendingPool.sol";
import "lendingPoolAddressProvider.sol";
import "hardhat/console.sol";

contract Wrapper   {
    ILendingPoolAddressesProvider provider;
    ILendingPool lPool;
    IProtocolDataProvider constant dataProvider = IProtocolDataProvider(address(0x744C1aaA95232EeF8A9994C4E0b3a89659D9AB79));
    IERC20 token;
    address pool;
    uint256 balance;
    uint256 allowance;
    address _asset;
    address owner;
   constructor(address _provider)  public {
       provider = ILendingPoolAddressesProvider(_provider);
       address lp = provider.getLendingPool();
        pool = lp;
        lPool = ILendingPool(address(lp));
        owner = msg.sender;
   }
  
   function getPoolAddress() external view returns(address){
       return pool;
   }
 
   function getSourceData() external view  returns (uint256 totalCollateralETH,uint256 totalDebtETH,uint256 availableBorrowsETH,uint256 currentLiquidationThreshold,uint256 ltv,uint256 healthFactor){
       return lPool.getUserAccountData(msg.sender);
   }

   function depositToPool(address asset,uint256 amount,bool isPull) external   {
        _asset = asset;
        IERC20 token =  IERC20(address(asset));
        token.approve(address(pool),amount);
        uint256 _allowance = token.allowance(address(this),pool);
        uint256 _balance = token.balanceOf(address(this));
        balance = _balance;
        allowance = _allowance; 

        require(_balance>=amount,"Not enough balance");
         lPool.deposit(asset,amount,address(this),0);
      
   }
   function withdrawFromPool(address asset, uint256 amount) external{
       lPool.withdraw(asset,amount,msg.sender);
   }

   function borrowFromPool(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode) external {
     lPool.borrow(asset, amount,  interestRateMode,  referralCode, address(this));
   }

   function repayeToPool(address asset, uint256 amount, uint256 rateMode) external {
       IERC20(asset).approve(address(pool), amount);
       lPool.repay(asset,amount,rateMode,address(this));
   }

   function calimFunds(address asset) external{
       require(msg.sender == owner,"only owner can claim");
        uint256  totalToken =   IERC20(asset).balanceOf(address(this));
        require(totalToken >0 ,"not enough balance");
        IERC20(asset).transfer(address(msg.sender),totalToken);

   }

}