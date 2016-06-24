import "EtherPromise.sol";

contract PromiseFactory {
  function create(address resolver) returns(EtherPromise) {
    return new EtherPromise(resolver, StubFactory(this));
  }
}
