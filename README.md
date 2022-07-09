# foundry-create2-deployer

**Currently a work in progress** - Currently stuck until Foundry implements multiple forks per test, as the script cannot read code deployed in the same transaction (I think)


`script/Create2Deployer.s.sol` serves as a basis for Foundry scripts meant to deploy contracts to a deterministic address on any network using `CREATE2_FACTORY.safeCreate2`, which has the following interface:

```solidity
interface ImmutableCreate2Factory {
    function safeCreate2(bytes32 salt , bytes memory contractCreationCode) external;
}
```

Where `salt` is a `bytes32` with the `msg.sender`'s address encoded as the first 160 bits, and `contractCreationCode` is the code to be deployed.

# Usage 

The `setUp()` method of `Create2DeployerBase.s.sol` performs the following checks and steps:

1. Check that the `KEYLESS_CREATE2_FACTORY` is deployed to the network
   -  If not, check that `KEYLESS_CREATE2_DEPLOYER` has sufficient funds to deploy the `KEYLESS_CREATE2_FACTORY`
      -  If not, sends funds (0.01 of the native token) to the `KEYLESS_CREATE2_DEPLOYER`
   -  Submit a pre-signed transaction from `KEYLESS_CREATE2_DEPLOYER` to deploy the `KEYLESS_CREATE2_FACTORY` 
2. Check that the `INEFFICIENT_IMMUTABLE_CREATE2_FACTORY` is deployed to the network
   - If not, submit a transaction to `KEYLESS_CREATE2` to deploy the `INEFFICIENT_IMMUTABLE_CREATE2_FACTORY`
3. Check that the `EFFICIENT_IMMUTABLE_CREATE2_FACTORY` is deployed to the network
   -  If not, submit a transaction to `INEFFICIENT_IMMUTABLE_CREATE2_FACTORY` to deploy the `EFFICIENT_IMMUTABLE_CREATE2_FACTORY`

When overriding script contracts call `super.setUp()`, this ensures that the `EFFICIENT_IMMUTABLE_CREATE2_FACTORY` is deployed to the network before the body of the script's `run()` function executed.