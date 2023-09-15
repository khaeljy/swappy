// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use starknet::deploy_syscall;

// Local imports.
use swappy::account::account::{Account, IAccountDispatcher, IAccountDispatcherTrait};

// Deploy the contract and return its dispatcher.
fn deploy(public_key: felt252) -> IAccountDispatcher {
    // Set up constructor arguments.
    let mut calldata = ArrayTrait::new();
    public_key.serialize(ref calldata);

    // Declare and deploy
    let (contract_address, _) = deploy_syscall(
        Account::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    // Return the dispatcher.
    // The dispatcher allows to interact with the contract based on its interface.
    IAccountDispatcher { contract_address }
}

#[test]
#[available_gas(2000000000)]
fn test_deploy() {
    let public_key: felt252 = 'test';
    let contract = deploy(public_key);

    assert(contract.get_public_key() == public_key, 'wrong public key');
}

#[test]
#[available_gas(2000000000)]
#[should_panic(expected: ('ALREADY_INITIALIZED','ENTRYPOINT_FAILED',))]
fn test_initialize_twice() {
    let public_key: felt252 = 'test';
    let contract = deploy(public_key);
    contract.initialize(public_key);
}
