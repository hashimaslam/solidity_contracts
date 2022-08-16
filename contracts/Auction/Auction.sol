//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract Auction is ERC721URIStorage {
    // static
    address payable public owner;
    uint256 public bidIncrement;
    uint256 public startTime;
    uint256 public autionEndTime;
    // state
    bool public canceled;
    uint256 public highestBindingBid;
    address payable public highestBidder;
    mapping(address => uint256) public fundsByBidder;
    bool ownerHasWithdrawn;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string nftURI;

    event LogBid(
        address bidder,
        uint256 bid,
        address highestBidder,
        uint256 highestBid,
        uint256 highestBindingBid
    );
    event LogWithdrawal(
        address withdrawer,
        address withdrawalAccount,
        uint256 amount
    );
    event LogCanceled();

    constructor(
        address payable _owner,
        uint256 _bidIncrement,
        uint256 _autionEndTime,
        string memory tokenName,
        string memory tokenSymbol,
        string memory _nftURI
    ) public ERC721(tokenName, tokenSymbol) {
        owner = _owner;
        bidIncrement = _bidIncrement;
        startTime = block.timestamp;
        autionEndTime = block.timestamp + _autionEndTime;
        nftURI = _nftURI;
    }

    function getHighestBid() public view returns (uint256) {
        return fundsByBidder[highestBidder];
    }

    function isAutionDone() public view returns (bool) {
        return block.timestamp >= autionEndTime;
    }

    function placeBid()
        public
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyNotCanceled
        onlyNotOwner
        returns (bool success)
    {
        uint256 newBid = fundsByBidder[msg.sender] + msg.value;
        require(msg.value > 0, "Value should not be Zero");
        require(newBid >= highestBindingBid, "New bid should be higher");

        uint256 highestBid = fundsByBidder[highestBidder];

        fundsByBidder[msg.sender] = newBid;

        if (newBid <= highestBid) {
            highestBindingBid = min(newBid + bidIncrement, highestBid);
        } else {
            if (msg.sender != highestBidder) {
                highestBidder = payable(msg.sender);
                highestBindingBid = min(newBid, highestBid + bidIncrement);
            }
            highestBid = newBid;
        }
        console.log(newBid, "new bid");
        emit LogBid(
            msg.sender,
            newBid,
            highestBidder,
            highestBid,
            highestBindingBid
        );

        return true;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        if (a < b) return a;
        return b;
    }

    function cancelAuction()
        external
        onlyOwner
        onlyBeforeEnd
        onlyNotCanceled
        returns (bool success)
    {
        canceled = true;
        emit LogCanceled();
        return true;
    }

    function withdraw()
        external
        onlyEndedOrCanceled
        onlyNotRecipient
        returns (bool success)
    {
        address withdrawalAccount;
        uint256 withdrawalAmount;

        if (canceled) {
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];
        } else {
            if (msg.sender == owner) {
                withdrawalAccount = highestBidder;
                withdrawalAmount = highestBindingBid;
                ownerHasWithdrawn = true;
            } else {
                withdrawalAccount = msg.sender;
                withdrawalAmount = fundsByBidder[withdrawalAccount];
            }
        }

        require(uint256(withdrawalAmount) != 0, "Nothing to withdraw");
        fundsByBidder[withdrawalAccount] -= withdrawalAmount;

        // send the funds
        address payable ownerAdd = payable(msg.sender);
        payable(ownerAdd).transfer(uint256(withdrawalAmount));

        emit LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);

        return true;
    }

    function withdrawAndCollect() external onlyRecipient {
        address withdrawalAccount;
        uint256 withdrawalAmount;
        withdrawalAccount = highestBidder;
        if (canceled) {
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];
        } else {
            if (ownerHasWithdrawn) {
                withdrawalAmount = fundsByBidder[highestBidder];
            } else {
                withdrawalAmount =
                    fundsByBidder[highestBidder] -
                    highestBindingBid;
            }
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
            _setTokenURI(newItemId, nftURI);
            _tokenIds.increment();
        }

        address payable ownerAdd = payable(msg.sender);
        if (withdrawalAmount != 0) {
            payable(ownerAdd).transfer(uint256(withdrawalAmount));
        }

        emit LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can access");
        _;
    }

    modifier onlyNotOwner() {
        require(msg.sender != owner, "owner can't have access");
        _;
    }

    modifier onlyAfterStart() {
        require(block.timestamp >= startTime, "Acution yet be started");

        _;
    }

    modifier onlyBeforeEnd() {
        require(block.timestamp <= autionEndTime, "Aution ended");
        _;
    }

    modifier onlyNotCanceled() {
        require(canceled == false, "Aution cancelled");
        _;
    }

    modifier onlyEndedOrCanceled() {
        require(
            block.timestamp >= autionEndTime || canceled == true,
            "Aution Not Ended or Cancelled"
        );
        _;
    }

    modifier onlyRecipient() {
        require(msg.sender == highestBidder, "only bidder who won can access");
        _;
    }
    modifier onlyNotRecipient() {
        require(
            msg.sender != highestBidder,
            "if you won the auction please use withdrawAndcollect function to collect your NFT or remaining "
        );
        _;
    }
}
