// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CustomizedERC20
 * @author github.com/codermaybe
 * @dev CustomizedERC20 is a customized ERC20 token with a few additional features.
 * @dev 本合约仅用于学习和研究。所有复现均按照eip721标准。详见：https://github.com/ethereum/ERCs/blob/master/ERCS/erc-721.md
 * @dev 自行复现的erc721各项功能。interface文件夹中的所有文件为官方文档移植
 * @dev 逐行按照官方文档翻译方法的实现需求，请允许我偷点小懒用翻译 *。*
 * @dev V1版本特性：自定义_baseURI，_nextToken，以及mint、burn等方法，丰富构造器和管理功能
 */
contract CE721_openzepplinV1 is ERC721URIStorage, ERC721Burnable, Ownable {
    constructor(
        string memory name,
        string memory symbol
    ) ERC721URIStorage(name, symbol) Ownable(msg.sender) {
        // 调用 Ownable 的构造函数，传递部署合约的地址作为所有者
    }

    // 重写 tokenURI 函数
    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
