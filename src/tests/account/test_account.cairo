use core::traits::Into;
use starknet::{
    deploy_syscall, get_contract_address, get_caller_address, ContractAddress,
    contract_address_const
};
use starknet::testing::{set_caller_address, set_contract_address, set_account_contract_address};
use openzeppelin::account::{AccountABIDispatcher, AccountABIDispatcherTrait};

use swappy::account::account::Account;

fn deploy(owner: ContractAddress) -> AccountABIDispatcher {
    // Set up constructor arguments.AccountABIDispatcher
    let mut calldata = ArrayTrait::new();
    owner.serialize(ref calldata);

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
    let owner = contract_address_const::<'OWNER'>();

    // When
    let contract = deploy(owner);
    // Then
    assert(contract.get_public_key() == owner.into(), 'wrong public key');
}
