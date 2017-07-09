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
    
    /* Period when token decrease in days. When elapsed token amount on balance become 0 */
    uint public decreasePeriod;

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
        uint pastDays = (now - balances[_owner].lastUpdateTime) / 1 days;
        uint realAmount = balances[_owner].amount * (decreasePeriod - pastDays) / decreasePeriod;
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
    function DecreasingToken(string _name, string _symbol, uint8 _decimals, uint _count, uint _decreasePeriod) {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
        totalSupply = _count;
        balances[msg.sender].amount = _count;
        decreasePeriod = _decreasePeriod;
    }
 
    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint _value) returns (bool) {
        if (msg.sender == owner) {
            uint senderRealAmount = balances[msg.sender].amount;
        } else {
            uint senderPastDays = (now - balances[msg.sender].lastUpdateTime) / 1 days;
            if (senderPastDays > decreasePeriod) {
                senderPastDays = decreasePeriod;
            }
            senderRealAmount = balances[msg.sender].amount * (decreasePeriod - senderPastDays) / decreasePeriod;
        }

        if (senderRealAmount >= _value) {
            if(_to == owner) {
                uint receiverRealAmount = balances[_to].amount;
            } else {
                uint receiverPastDays = (now - balances[_to].lastUpdateTime) / 1 days;
                if (receiverPastDays > decreasePeriod) {
                    receiverPastDays = decreasePeriod;
                }
                receiverRealAmount = balances[_to].amount * (decreasePeriod - receiverPastDays) / decreasePeriod;
            }
            
            balances[msg.sender].amount = senderRealAmount - _value;
            balances[msg.sender].lastUpdateTime = now;
            balances[_to].amount = receiverRealAmount + _value;
            balances[_to].lastUpdateTime = now;
            
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
        if (_from == owner) {
            uint senderRealAmount = balances[_from].amount;
        } else {
            uint senderPastDays = (now - balances[_from].lastUpdateTime) / 1 days;
            if (senderPastDays > decreasePeriod) {
                senderPastDays = decreasePeriod;
            }
            senderRealAmount = balances[_from].amount * (decreasePeriod - senderPastDays) / decreasePeriod;
        }
        
        var avail = allowances[_from][msg.sender]
                  > senderRealAmount ? senderRealAmount
                                    : allowances[_from][msg.sender];
                                    
        if (avail >= _value) {
            allowances[_from][msg.sender] -= _value;
            
            if (_to == owner) {
                uint receiverRealAmount = balances[_to].amount;
            } else {
                uint receiverPastDays = (now - balances[_to].lastUpdateTime) / 1 days;
                if (receiverPastDays > decreasePeriod) {
                    receiverPastDays = decreasePeriod;
                }
                receiverRealAmount = balances[_to].amount * (decreasePeriod - receiverPastDays) / decreasePeriod;
            }
            
            balances[_from].amount = senderRealAmount - _value;
            balances[_from].lastUpdateTime = now;
            
            balances[_to].amount = receiverRealAmount + _value;
            balances[_to].lastUpdateTime = now;

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