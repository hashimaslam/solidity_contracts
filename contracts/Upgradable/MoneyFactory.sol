pragma solidity ^0.8.4;
import "./CloneFactory.sol";
import "hardhat/console.sol";

contract MoneyFactory is CloneFactory {
    MoneyProxy[] public children;
    address public masterContract;
    address public implementation;

    function addMaster(address _masterContract) external {
        masterContract = _masterContract;
    }

    function addImplementationAddr(address _implementation) external {
        implementation = _implementation;
    }

    function createChild() external payable {
        MoneyProxy child = MoneyProxy(createClone(masterContract));
        address factoryAddr = address(this);
        child.initContract(factoryAddr);
        children.push(child);
    }

    function getChildren() external view returns (MoneyProxy[] memory) {
        return children;
    }

    function getImpContract() public payable returns (address) {
        return implementation;
    }
}

contract MoneyProxy {
uint256 public amount;
    address public factory;
    address public implementation;
    uint public sample;
    
    // address public implementation;
    // address public implContract;
    function initContract(address _factory) external {
        factory = _factory;
    }


    fallback() external {
        (bool success, bytes memory data) = factory.call(
            abi.encodeWithSignature("getImpContract()")
        );
        implementation = abi.decode(data, (address));
        console.log(implementation,"from console");
        address _impl = abi.decode(data, (address));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    // function claimAmount()  public payable returns(uint256) {
    //     require(factory != address(0),"Factory address should be added");
    //     (bool factSucess, bytes memory impData) = address(factory).delegatecall(
    //         abi.encodeWithSignature("getImpContract()")
    //     );

    //      require(factSucess,"Delegate call failed");
    //     // implementation = abi.decode(impData,(address));

    //    (bool success, bytes memory data) = address(implContract).delegatecall(
    //         abi.encodeWithSignature("calimMoney()")
    //     );
    //     //  console.log("impData",implementation);
    //     require(success,"Delegate call failed");
    //     return amount;
    // }

    // function sample() external view returns (string memory){
    //     return "asdasdc";
    // }
}
