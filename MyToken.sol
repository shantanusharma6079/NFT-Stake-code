// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MyToken is ERC20, ERC721Holder, Ownable {
    IERC721 public nft;

    struct StakingInfo {
        address owner;
        uint stakedTimestamp;
        uint duration;
        uint amount;
    }

    mapping(uint => StakingInfo) public stakingInfo;

    constructor(address _nft) ERC20("MyToken", "MTK") {
        nft = IERC721(_nft);
    }

    // function mint(address to, uint256 amount) public onlyOwner {
    //     _mint(to, amount);
    // }

    function stake(uint256 _tokenId, uint256 _duration) external {
        require(_duration == 7 || _duration == 14 || _duration == 21 || _duration == 28, "Invalid duration");
        uint duration = _duration * 24 * 60 * 60;
        require(stakingInfo[_tokenId].amount == 0, "Token already staked");

        nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        uint amount = calculateReward(_tokenId);
        stakingInfo[_tokenId] = StakingInfo(msg.sender, block.timestamp, duration, amount);

    }

    function calculateReward(uint _tokenId) public view returns(uint) {
        uint duration = stakingInfo[_tokenId].duration;
        uint amount = stakingInfo[_tokenId].amount;

        if (duration == 604800) {
            return amount * 10/100;
        } else if (duration == 1209600) {
            return amount * 20/100;
        } else if (duration == 1814400) {
            return amount * 30/100;
        } else if (duration == 2419200) {
            return amount * 40/100;
        } else {
            revert("Invalid duration");
        }
    }

    function unstake(uint _tokenId) external {
        require(stakingInfo[_tokenId].owner == msg.sender, "You are not the owner");
        require(block.timestamp >= stakingInfo[_tokenId].stakedTimestamp + stakingInfo[_tokenId].duration, "Token is not staked yet");

        _mint(msg.sender, calculateReward(_tokenId));
        nft.transferFrom(address(this), msg.sender, _tokenId);
        delete stakingInfo[_tokenId];
    }
}
