import "StubFactory.sol";
contract EtherPromise {
  struct Callback { bytes4 sig; address destination; }
  enum States { Pending, Resolved }

  StubFactory promiseFactory;

  address public creator;
  address public resolver;
  States public state;
  uint public value;

  Callback public resolveHandler;
  EtherPromise public nextPromise;


  function EtherPromise(address _resolver, StubFactory _promiseFactory) {
    resolver = _resolver;
    creator = msg.sender;
    promiseFactory = _promiseFactory;
  }

  function resolve(uint _value) {
    if (msg.sender == resolver) {
      value = _value;
      state = States.Resolved;
      if (nextPromise != address(0)) {
        var (sig, destination) = nextPromise.resolveHandler();
        uint nextValue = this.callAndGetReturn(destination, sig, _value);
        nextPromise.resolve(nextValue);
      }
    }
  }

  function setResolveHandler(bytes4 sig, address destination) {
    resolveHandler = Callback(sig, destination);
  }

  function andThen(string resolveSignature, address resolveDestination) returns(EtherPromise) {
    nextPromise = EtherPromise(promiseFactory.create(this));
    nextPromise.setResolveHandler(stringToSig(resolveSignature), resolveDestination);
    return nextPromise;
  }

  function stringToSig(string signature) returns(bytes4) {
    return bytes4(sha3(signature));
  }

  function callAndGetReturn(address destination, bytes4 sig, uint arg) returns(uint) {
    uint r;
    uint v;

    assembly {
      mstore(mload(0x40), sig)
      mstore(add(mload(0x40), 4), arg)
      r := call(sub(gas, 10000), destination, 0, mload(0x40), 36, mload(0x40), 32)
      v := mload(mload(0x40))
    }

    if (r != 1) throw;
    return v;
  }
}
