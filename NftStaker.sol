// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract NftStaker {
    IERC1155 public parentNFT;

    struct Stake {
        uint256 tokenId;
        uint256 rate;
        uint256 timestamp;
    }
    
    // need dynamic value
    //  SS = 50
    //  S = 30
    //  A = 15
    //  B = 5
    //  C = 0

    mapping(uint256 => uint256) public seasonSupply;
    uint256 totalMaintoken;
    uint public Curseason = 1;
    uint public stealpossible = 30;
    
    address owner;
    uint counterNFT;

    // map staker address to stake details
    mapping(address => Stake) public stakes;

    // map staker to total staking time 
    //mapping(address => uint256) public stakingTime;

    mapping(address => uint) public rewards;    

    constructor() {
        parentNFT = IERC1155(0xd9145CCE52D386f254917e481eB44e9943F39138); // Change it to your NFT contract addr
        totalMaintoken = 100;  // if parent contract change init minting, this var must change same
        owner = msg.sender;
        counterNFT = 3;
    }

    modifier updateReward(address _account) {
        uint256 rewardPerTokenStored = rewards[_account];  // 0
        uint256 addReward = rewardPerToken(_account);  // 
        rewardPerTokenStored += addReward;
        totalMaintoken += addReward;

    //    if (_account != address(0)) {
            rewards[_account] = rewardPerTokenStored;
    //    }

        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Permission erR1!");
        _;
    }


    function rewardPerToken(address _account) public returns (uint256) {
        //require(stakes[_account].tokenId > 0, "not stake");  // need edit

        // current hardcording 
        require(block.timestamp - stakes[_account].timestamp > 10, "cycle cool time not yet erR!");

        uint256 pertokenSeason = parentNFT.viewSeason(stakes[_account].tokenId);
        
        // * 1e18 와 같은 수식 필요. // 수치 조정 필요 
        return (stakes[_account].rate * (block.timestamp - stakes[_account].timestamp)) / seasonSupply[pertokenSeason];
    }


    function stake(uint256 _tokenId) public {
        require(stakes[msg.sender].tokenId == 0, "unstack require");
        require(parentNFT.balanceOf(msg.sender, _tokenId) != 0, "Not token Owner!");

        uint256 rate = parentNFT.viewTokenRate(_tokenId);

        parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId, 1, "0x00");
        stakes[msg.sender] = Stake(_tokenId, rate, block.timestamp); 
        
    } 

    // once unstack take place, All stacking amount withdraw
    function unstake(address _account) public updateReward(_account) {
        require(stakes[_account].tokenId > 0, "No Stake erR!");

        parentNFT.safeTransferFrom(address(this), _account, stakes[_account].tokenId, 1, "0x00");
        //stakingTime[_account] += (block.timestamp - stakes[_account].timestamp);
        delete stakes[_account];
    }

    function chargeSubtoken(uint256 _amount) public onlyOwner {
        parentNFT.safeTransferFrom(msg.sender, address(this), 0, _amount, "0x00");
    }

    // unstake -> getReward
    function getReward(address _account) public {
        uint256 reward = rewards[_account];
        require(reward > 0, "No reward erR!");
        rewards[_account] = 0;
        parentNFT.safeTransferFrom(address(this), _account, 0, reward, "0x00");
    }      

    function steal(address _owner, address _stealer, uint _amount, uint _stealtokenId) public onlyOwner{
        require(parentNFT.balanceOf(_stealer, _stealtokenId) > 0, "Not have Stealer Token1");
        require(parentNFT.checkStealer(_stealtokenId), "Not have Stealer Token2");

        require(parentNFT.balanceOf(_owner, 0) > _amount, "owner : not enough");
        require(parentNFT.balanceOf(_owner, 0)*20/100 < _amount, "excess steal amount");

        uint randNonce = 0;
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 100;

        if(random < stealpossible){  // steal success
            parentNFT.safeTransferFrom(_owner, _stealer, 0, _amount, "0x00");
        } 
        else {  // steal fail
            parentNFT.burn(_stealer, 0, _amount);
            parentNFT.burn(_stealer, _stealtokenId, 1);
        }
    }


    function mintMush(address _account, string calldata _tokenuri, uint _tokenRate) public onlyOwner{
        uint randNonce = 0;
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 1000;


        parentNFT.mintMush(_account, counterNFT, _tokenuri, _tokenRate);
        counterNFT++;
        seasonSupply[Curseason] += 1;
    }

    function seasonUpdate() public onlyOwner {
        Curseason++;
    }
   

    // function expectReward(address _account) public updateReward(_account) returns(uint256){
        
    // }

    // contract가 토큰 받을 때 호출되는 함수
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

    function mintMush(address _account, uint _tokenId, string memory _tokenuri, uint256 _tokenRate) external;

    function viewTokenRate(uint256 _tokenId) external returns(uint256);

    function checkStealer(uint _stealtokenId) external view returns(bool);

    function burn(address _account, uint _tokenId, uint _amount) external;

    function viewSeason(uint256 _tokenId) external returns(uint256);

    function updateSeason() external;

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
