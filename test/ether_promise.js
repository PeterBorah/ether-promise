contract('EtherPromise', function(accounts) {
  var PENDING = 0;
  var RESOLVED = 1;
  var REJECTED = 2;

  it("should store the authorized resolver", function(done) {
    var ether_promise;

    EtherPromise.new(accounts[0], PromiseFactory.deployed().address).
      then(function(result) { ether_promise = result; }).
      then(function() { return ether_promise.resolver() }).
      then(function(result) {
        assert.equal(result, accounts[0]);
        done();
      }).catch(done);
  });

  it("should let the resolver resolve the promise", function(done) {
    var ether_promise;

    EtherPromise.new(accounts[0], PromiseFactory.deployed().address).
      then(function(result) { ether_promise = result; }).
      then(function() { return ether_promise.state() }).
      then(function(result) {
        assert.equal(result, PENDING);
      }).
      then(function() { return ether_promise.resolve(4) }).
      then(function() { return ether_promise.state() }).
      then(function(result) {
        assert.equal(result, RESOLVED);
      }).
      then(function() { return ether_promise.value() }).
      then(function(result) {
        assert.equal(result, 4);
        done();
      }).catch(done);
  });

  it("should let consumer contracts register a resolve callback", function(done) {
    var ether_promise;
    var consumer;

    EtherPromise.new(accounts[0], PromiseFactory.deployed().address).
      then(function(result) { ether_promise = result; }).
      then(function() { return Consumer.new() }).
      then(function(result) { consumer = result }).
      then(function() { return ether_promise.andThen("resolveCallback(uint256)", consumer.address) }).
      then(function() { return ether_promise.resolve(42) }).
      then(function() { return consumer.value() }).
      then(function(result) {
        assert.equal(result, 42);
      }).
      then(function() { return consumer.isResolved() }).
      then(function(result) {
        assert.equal(result, true)
        done();
      }).catch(done);
  });

  it("andThen should return a promise for chaining", function(done) {
    var ether_promise;
    var consumer;

    EtherPromise.new(accounts[0], PromiseFactory.deployed().address).
      then(function(result) { ether_promise = result; }).
      then(function() { return Consumer.new() }).
      then(function(result) { consumer = result }).
      then(function() { return consumer.registerChainedCallbacks(ether_promise.address); }).
      then(function() { return ether_promise.resolve(42) }).
      then(function() { return consumer.isResolved() }).
      then(function(result) {
        assert.equal(result, true)
      }).
      then(function() { return consumer.value() }).
      then(function(result) {
        assert.equal(result, 46);
        done();
      }).catch(done);
  });
});
