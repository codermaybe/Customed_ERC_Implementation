//SPDX-License-Identifier: MIT
/**
 * @title CustomizedERC1155
 * @author github.com/codermaybe
 * @dev CustomizedERC1155 is a customized ERC20 token with a few additional features.
 * @dev 本合约仅用于学习和研究。所有复现均按照eip721标准。详见：https://github.com/ethereum/ERCs/blob/master/ERCS/erc-1155.md
 * @dev 自行复现的erc1155各项功能。interface文件夹中的所有文件为官方文档移植
 * @dev 逐行按照官方文档翻译方法的实现需求，请允许我偷点小懒用翻译 *。*
 * @dev ERC1155标准相对复杂许多，建议直接使用openzepplin。
 * @dev V1版本特性：data字段暂不丰富特性
 */


pragma solidity ^0.8.28;

import {ERC1155} from "./interface/ERC1155.sol";
import {ERC1155TokenReceiver} from "./interface/ERC1155TokenReceiver.sol";

contract CE1155V1 {

      // mapping(uint256 =>address) public _ownerOf; 代币对应持有者
      // mapping(address =>uint256) public _balanceOf; 拥有者余额？仅能对应类似以太坊等余额吗  





      /**
        @notice 将 `_value` 数量的 `_id` 从 `_from` 地址转移到指定的 `_to` 地址（带有安全调用）。
        @dev 调用者必须被批准管理从 `_from` 帐户转移出的代币（参见标准的“批准”部分）。
        如果 `_to` 是零地址，则必须回退。
        如果代币 `_id` 的持有者余额低于发送的 `_value`，则必须回退。
        在任何其他错误情况下，都必须回退。
        必须发出 `TransferSingle` 事件以反映余额变化（参见标准的“安全转移规则”部分）。
        在满足上述条件后，此函数必须检查 `_to` 是否为智能合约（例如，代码大小 > 0）。如果是，则必须在 `_to` 上调用 `onERC1155Received` 并采取适当的操作（参见标准的“安全转移规则”部分）。
        @param _from     源地址
        @param _to       目标地址
        @param _id       代币类型的 ID
        @param _value    转移数量
        @param _data     附加数据，没有指定格式，必须在对 `_to` 的 `onERC1155Received` 调用中保持不变
    */
    //Safe Transfer Rules :https://github.com/ethereum/ERCs/blob/master/ERCS/erc-1155.md#safe-transfer-rules  
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external {
        require(批准[_from][msg.sender],unicode"无权进行此转账，未经授权或不是本人");
        require(_to != address(0), unicode"不可转账至零地址");
        require(拥有者[_id].余额 >= _value,unicode"余额不足");

       
        拥有者[_id].余额 -= _value;//在调用接收者合约上的 ERC1155TokenReceiver hook之前，转账的余额必须已被更新   Scenario#6
        emit TransferSingle(msg.sender,_from,_to,_id,_value);//在调用接收者合约上的 ERC1155TokenReceiver hook之前，必须已发出转账事件以反映余额变更。 Scenario#6

        if(_to.code.length > 0){
            //onERC1155Received 或 onERC1155BatchReceived 必须在接收转账的合约上至少被调用一个
           bytes4 retval1 =  ERC1155TokenReceiver(_to).onERC1155Received(msg.sender,_from,_id,_value,_data);//onERC1155Received必须被调用，且必须得遵循规则
           bytes4 retval2 =  ERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender,_from,_id,_value,_data);//可选  这个函数可能没有被调用，但是必须得遵循规则
        require(
            retval1 ==
                bytes4(
                    keccak256(
                        "onERC1155Received(address,address,uint256,uint256,bytes)"
                    )
                ),
            unicode"此合约地址未实现ERC721TokenReceiver"
        );
        //需修正或完善部分
        require(
            retval2 ==
                bytes4(
                    keccak256(
                        "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                    )
                ),
            unicode"此合约地址未实现ERC721TokenReceiver"
        );
        }
    };

    /**
        @notice 将 `_values` 数量的 `_ids` 从 `_from` 地址转移到指定的 `_to` 地址（带有安全调用）。
        @dev 调用者必须被批准管理从 `_from` 帐户转移出的代币（参见标准的“批准”部分）。
        如果 `_to` 是零地址，则必须回退。
        如果 `_ids` 的长度与 `_values` 的长度不相同，则必须回退。
        如果 `_ids` 中代币持有者的任何余额低于发送给接收者的 `_values` 中的相应数量，则必须回退。
        在任何其他错误情况下，都必须回退。
        必须发出 `TransferSingle` 或 `TransferBatch` 事件，以便反映所有余额变化（参见标准的“安全转移规则”部分）。
        余额变化和事件必须遵循数组的顺序（`_ids[0]/_values[0]` 在 `_ids[1]/_values[1]` 之前，等等）。
        在满足批量转移的上述条件后，此函数必须检查 `_to` 是否为智能合约（例如，代码大小 > 0）。如果是，则必须在 `_to` 上调用相关的 `ERC1155TokenReceiver` 钩子并采取适当的操作（参见标准的“安全转移规则”部分）。
        @param _from     源地址
        @param _to       目标地址
        @param _ids      每个代币类型的 ID（顺序和长度必须与 `_values` 数组匹配）
        @param _values   每个代币类型的转移数量（顺序和长度必须与 `_ids` 数组匹配）
        @param _data     附加数据，没有指定格式，必须在对 `_to` 的 `ERC1155TokenReceiver` 钩子的调用中保持不变
    */
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external{
        require(批准[_from][msg.sender],unicode"无权进行此转账，未经授权或不是本人");
        require(_to!= address(0), unicode"不可转账至零地址");
        require(_ids.length == _values.length, unicode"参数长度不匹配");
        for(uint256 i = 0; i < _ids.length; i++){
            require(拥有者[_ids[i]].余额 >= _values[i],unicode"余额不足");
            记录表[_from][_ids[i]].余额 -= _values[i];
            emit TransferSingle(msg.sender,_from,_to,_ids[i],_values[i]);
        }

        if(_to.code.length > 0){
            //onERC1155Received 或 onERC1155BatchReceived 必须在接收转账的合约上至少被调用一个
           bytes4 retval1 =  ERC1155TokenReceiver(_to).onERC1155Received(msg.sender,_from,_id,_value,_data);//onERC1155Received必须被调用，且必须得遵循规则
           bytes4 retval2 =  ERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender,_from,_id,_value,_data);//可选  这个函数可能没有被调用，但是必须得遵循规则
        require(
            retval1 ==
                bytes4(
                    keccak256(
                        "onERC1155Received(address,address,uint256,uint256,bytes)"
                    )
                ),
            unicode"此合约地址未实现ERC721TokenReceiver"
        );
        //需修正或完善部分
        require(
            retval2 ==
                bytes4(
                    keccak256(
                        "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                    )
                ),
            unicode"此合约地址未实现ERC721TokenReceiver"
        );
        }
    };

    /**
        @notice 获取帐户代币的余额。
        @param _owner    代币持有者的地址
        @param _id       代币的 ID
        @return         请求的代币类型的 `_owner` 的余额
    */
    function balanceOf(address _owner, uint256 _id) external view returns (uint256){

        return 记录表[_owner][_id].余额;
    };

    /**
        @notice 获取多个帐户/代币对的余额
        @param _owners   代币持有者的地址
        @param _ids      代币的 ID
        @return         请求的代币类型的 `_owner` 的余额（即，每个 (owner, id) 对的余额）
    */
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory){
        uint256[] memory 余额 = new uint256[](_owners.length);
        for(uint256 i = 0; i < _owners.length; i++){
            余额[i] = 记录表[_owners[i]][_ids[i]].余额;
        }
    };

     /**
        @notice 启用或禁用第三方（“操作员”）管理调用者所有代币的批准。
        @dev 成功时必须发出 `ApprovalForAll` 事件。
        @param _operator  添加到授权操作员集合的地址
        @param _approved  如果操作员被批准，则为 true；如果撤销批准，则为 false
    */
    function setApprovalForAll(address _operator, bool _approved) external{
        批准[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender,_operator,_approved);
    };

    /**
        @notice 查询给定所有者的操作员的批准状态。
        @param _owner     代币的所有者
        @param _operator  授权操作员的地址
        @return         如果操作员被批准，则为 true；如果未被批准，则为 false
    */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
        return 批准[_owner][_operator];
    };
    
}
