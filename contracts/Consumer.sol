import "EtherPromise.sol";

contract Consumer {
  bool public isResolved;
  uint public value;

  function resolveCallback(uint _value) {
    value = _value;
    isResolved = true;
  }

  function firstChainedCallback(uint _value) returns(uint) {
    return (_value + 4);
  }

  function secondChainedCallback(uint _value) {
    value = _value;
    isResolved = true;
  }

  function registerChainedCallbacks(EtherPromise promise1) {
    EtherPromise promise2 = promise1.andThen("firstChainedCallback(uint256)", this);
    promise2.andThen("secondChainedCallback(uint256)", this);
  }
}
