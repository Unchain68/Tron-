// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract NftStaker {
    IERC1155 public parentNFT;

    struct Stake {
        uint256 tokenId;
        uint256 amount;
        uint256 timestamp;
    }

    uint256 totalSupply;
    uint constant tokenRate = 10;
    address owner;
    uint counterNFT;

    // map staker address to stake details
    mapping(address => Stake) public stakes;

    // map staker to total staking time 
    //mapping(address => uint256) public stakingTime;

    mapping(address => uint) public rewards;    

    constructor() {
        parentNFT = IERC1155(0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d); // Change it to your NFT contract addr
        totalSupply = 100;  // if parent contract change init minting, this var must change same
        owner = msg.sender;
        counterNFT = 3;
    }

    modifier updateReward(address _account) {
        uint256 rewardPerTokenStored = rewards[_account];
        uint256 addReward = rewardPerToken(_account);
        rewardPerTokenStored += addReward;
        totalSupply += addReward;

        if (_account != address(0)) {
            rewards[_account] = rewardPerTokenStored;
        }

        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Permission erR1!");

        _;
    }

    function rewardPerToken(address _account) public view returns (uint256) {
        if (totalSupply == 0) {
            return 0;
        }
        require(block.timestamp - stakes[_account].timestamp > 1000, "cycle cool time not yet erR!");
        
        // * 1e18 와 같은 수식 필요.
        return (stakes[_account].amount * (block.timestamp - stakes[_account].timestamp)) / totalSupply / tokenRate;
    }

    // reward cool time
    // function lastTimeReward(address _account) public view returns (uint) {
        
    //     return block.timestamp; 
    // }



    function stake(uint256 _tokenId, uint256 _amount) public {
        require(stakes[msg.sender].amount == 0, "unstack require");

        stakes[msg.sender] = Stake(_tokenId, _amount, block.timestamp); 
        parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "0x00");
        
    } 

    // once unstack take place, All stacking amount withdraw
    function unstake(address _account) public updateReward(_account) {
        require(stakes[_account].amount > 0, "No Stake erR!");

        parentNFT.safeTransferFrom(address(this), _account, stakes[_account].tokenId, stakes[msg.sender].amount, "0x00");
        //stakingTime[_account] += (block.timestamp - stakes[_account].timestamp);
        delete stakes[_account];
    }
    
    function getReward(address _account) public updateReward(_account) returns(uint256) {
        uint256 reward = rewards[_account];
        require(reward > 0, "No reward erR!");
            rewards[_account] = 0;
            parentNFT.safeTransferFrom(address(this), _account, 1, reward, "0x00");
            
            return reward;
    }      

    function stealSubtoken(address _from, address _to, uint _amount) public onlyOwner{
        parentNFT.safeTransferFrom(_from, _to, 1, _amount, "0x00");
    }

    // function mint() public {
    //     parentNFT.setApprovalForAll(address(this), true);
    // }

    function mintNFT(address _account, string calldata _tokenuri) public onlyOwner{
        parentNFT.minting(_account, counterNFT, _tokenuri);
        counterNFT++;
    }
   

    // function expectReward(address _account) public updateReward(_account) returns(uint256){
        
    // }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

}

interface IERC1155 {
    function uri(uint256 tokenId) external view returns (string memory);
    
    function setTokenUri(uint256 tokenId, string memory uri, uint opt) external;

    function setStakeContract(address _contract) external;

    function minting(address _account, uint _tokenId, string memory _tokenuri) external;

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}
