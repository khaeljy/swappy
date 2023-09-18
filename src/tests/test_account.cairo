use starknet::deploy_syscall;
use openzeppelin::account::{AccountABIDispatcher, AccountABIDispatcherTrait};

use swappy::account::account::Account;

// Deploy the contract and return its dispatcher.
fn deploy(public_key: felt252) -> AccountABIDispatcher {
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
    AccountABIDispatcher { contract_address }
}

#[test]
#[available_gas(2000000000)]
fn test_deploy() {
    // Given
    let public_key: felt252 = 'test';

    // When
    let contract = deploy(public_key);

    // Then
    assert(contract.get_public_key() == public_key, 'wrong public key');
}
