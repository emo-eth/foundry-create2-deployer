// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface ImmutableCreate2Factory {
    function safeCreate2(bytes32, bytes memory) external;
}

contract Create2DeployScriptBase is Script, Test {
    address private constant KEYLESS_CREATE2_DEPLOYER =
        0x4c8D290a1B368ac4728d83a9e8321fC3af2b39b1;
    address private constant KEYLESS_CREATE2_FACTORY =
        0x7A0D94F55792C434d74a40883C6ed8545E406D12;
    address private constant INEFFICIENT_IMMUTABLE_CREATE2_FACTORY =
        0xcfA3A7637547094fF06246817a35B8333C315196;
    address private constant EFFICIENT_IMMUTABLE_CREATE2_FACTORY =
        0x0000000000FFe8B47B3e2130213B802212439497;
    ImmutableCreate2Factory constant CREATE2_DEPLOYER =
        ImmutableCreate2Factory(EFFICIENT_IMMUTABLE_CREATE2_FACTORY);

    function setUp() public {
        vm.broadcast();
        _checkOrDeployKeylessCreate2();
        _checkOrDeployInefficientImmutableCreate2Factory();
        _checkOrDeployEfficientImmutableCreate2Factory();
    }

    function _checkOrDeployKeylessCreate2() private {
        if (KEYLESS_CREATE2_FACTORY.code.length == 0) {
            emit log_string("No Keyless CREATE2 address deployed.");

            if (KEYLESS_CREATE2_DEPLOYER.balance < 0.01 ether) {
                emit log_named_address(
                    "KEYLESS_CREATE2_DEPLOYER does not have sufficient funds. Sending funds to deployer address:",
                    KEYLESS_CREATE2_DEPLOYER
                );

                (bool success, ) = KEYLESS_CREATE2_DEPLOYER.call{
                    value: 0.01 ether
                }("");
                if (!success) {
                    revert("Unable to send funds to KEYLESS_CREATE2_DEPLOYER");
                }
                // TODO: fork and wait for block?
            }
            string[] memory ffiArgs = new string[](2);
            ffiArgs[0] = "bash";
            ffiArgs[1] = "submit_presigned_keyless_create.sh";
            bytes memory keylessCreateResult = vm.ffi(ffiArgs);
            _checkKeylessCreateResult(keylessCreateResult);
            // TODO: fork and wait for block?
        }
    }

    function _checkOrDeployInefficientImmutableCreate2Factory() private {
        if (INEFFICIENT_IMMUTABLE_CREATE2_FACTORY.code.length == 0) {
            bytes memory calldata_ = _getCalldata("inefficient_create2");
            (bool success, ) = KEYLESS_CREATE2_FACTORY.call(calldata_);
            if (!success) {
                revert(
                    "Unable to deploy INEFFICIENT_IMMUTABLE_CREATE2_FACTORY"
                );
            }
            // TODO: fork and wait for block?
        }
    }

    function _checkOrDeployEfficientImmutableCreate2Factory() private {
        if (INEFFICIENT_IMMUTABLE_CREATE2_FACTORY.code.length == 0) {
            bytes memory calldata_ = _getCalldata("efficient_create2");
            (bool success, ) = INEFFICIENT_IMMUTABLE_CREATE2_FACTORY.call(
                calldata_
            );
            if (!success) {
                revert("Unable to deploy EFFICIENT_IMMUTABLE_CREATE2_FACTORY");
            }
            // TODO: fork and wait for block?
        }
    }

    function _checkKeylessCreateResult(bytes memory result) private {
        // todo: parse and check result of script, currently output is piped to /dev/null
    }

    function _getCalldata(string memory fileName)
        private
        returns (bytes memory)
    {
        string[] memory ffiArgs = new string[](2);
        ffiArgs[0] = "cat";
        ffiArgs[1] = fileName;
        return vm.ffi(ffiArgs);
    }
}
