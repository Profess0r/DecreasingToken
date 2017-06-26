pragma solidity ^0.4.4;
import './Object.sol';
import './ERC20.sol';

contract DecreasingToken is Object, ERC20 {
        
    /* Short description of token */
    string public name;
    string public symbol;
    
    /* Total count of tokens exist */
    uint public totalSupply;

    /* Fixed point position */
    uint8 public decimals;
    

    struct Balance {
        uint amount;
        uint lastUpdateTime;
    }
    
    /* Token approvement system */
    mapping(address => Balance) balances;
    mapping(address => mapping(address => uint)) allowances;
 
    /**
     * @dev Get balance of plain address
     * @param _owner is a target address
     * @return amount of tokens on balance
     */
    function balanceOf(address _owner) constant returns (uint256) { 
        uint pastDays = (block.timestamp - balances[_owner].lastUpdateTime) / (60 * 60 * 24);
        uint realAmount = balances[_owner].amount * (100 - pastDays) / 100;
        return realAmount; 
    }
 
    /**
     * @dev Take allowed tokens
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) constant returns (uint256)
    { return allowances[_owner][_spender]; }

    /* Token constructor */
    function DecreasingToken(string _name, string _symbol, uint8 _decimals, uint _count) {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
        totalSupply = _count;
        balances[msg.sender].amount = _count;
    }
 
    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint _value) returns (bool) {
        uint senderPastDays = (block.timestamp - balances[msg.sender].lastUpdateTime) / (60 * 60 * 24);
        uint senderRealAmount = balances[msg.sender].amount * (100 - senderPastDays) / 100;
        
        if (senderRealAmount >= _value) {
            uint receiverPastDays = (block.timestamp - balances[_to].lastUpdateTime) / (60 * 60 * 24);
            uint receiverRealAmount = balances[_to].amount * (100 - receiverPastDays) / 100;
            
            balances[msg.sender].amount = senderRealAmount - _value;
            balances[msg.sender].lastUpdateTime = block.timestamp;
            balances[_to].amount = receiverRealAmount + _value;
            balances[_to].lastUpdateTime = block.timestamp;
            
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer with approvement mechainsm
     * @param _from source address, `_value` tokens shold be approved for `sender`
     * @param _to destination address
     * @param _value amount of token values to send 
     * @notice from `_from` will be sended `_value` tokens to `_to`
     * @return `true` when transfer is done
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        uint senderPastDays = (block.timestamp - balances[_from].lastUpdateTime) / (60 * 60 * 24);
        uint senderRealAmount = balances[_from].amount * (100 - senderPastDays) / 100;
        
        var avail = allowances[_from][msg.sender]
                  > senderRealAmount ? senderRealAmount
                                    : allowances[_from][msg.sender];
                                    
        if (avail >= _value) {
            allowances[_from][msg.sender] -= _value;
            
            uint receiverPastDays = (block.timestamp - balances[_to].lastUpdateTime) / (60 * 60 * 24);
            uint receiverRealAmount = balances[_to].amount * (100 - receiverPastDays) / 100;
            
            balances[_from].amount = senderRealAmount - _value;
            balances[_from].lastUpdateTime = block.timestamp;
            
            balances[_to].amount = receiverRealAmount + _value;
            balances[_to].lastUpdateTime = block.timestamp;

            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _spender target address (future requester)
     * @param _value amount of token values for approving
     */
    function approve(address _spender, uint256 _value) returns (bool) {
        allowances[msg.sender][_spender] += _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _spender target address (future requester)
     */
    function unapprove(address _spender)
    { allowances[msg.sender][_spender] = 0; }
    
}