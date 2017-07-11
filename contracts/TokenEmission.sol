pragma solidity ^0.4.4;
import './DecreasingToken.sol';

contract TokenEmission is DecreasingToken {
    function TokenEmission(string _name, string _symbol, uint8 _decimals,
                           uint _start_count, uint _decreasePeriod)
             DecreasingToken(_name, _symbol, _decimals, _start_count, _decreasePeriod)
    {}

    /**
     * @dev Token emission
     * @param _value amount of token values to emit
     * @notice owner balance will be increased by `_value`
     */
    function emission(uint _value) onlyOwner {
        // Overflow check
        if (_value + totalSupply < totalSupply) throw;

        totalSupply     += _value;
        balances[owner].amount += _value;
    }

}