use core::traits::Into;
use starknet::{
    deploy_syscall, get_contract_address, get_caller_address, ContractAddress,
    contract_address_const
};
use starknet::testing::{set_caller_address, set_contract_address, set_account_contract_address};
use openzeppelin::account::{AccountABIDispatcher, AccountABIDispatcherTrait};

use swappy::account::account::Account;
use swappy::account::account::{ISwappyAccountDispatcher, ISwappyAccountDispatcherTrait};

use debug::PrintTrait;

fn deploy(owner: ContractAddress) -> ContractAddress {
    // Set up constructor arguments.AccountABIDispatcher
    let mut calldata = ArrayTrait::new();
    owner.serialize(ref calldata);

    // Declare and deploy
    let (contract_address, _) = deploy_syscall(
        Account::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    contract_address
}

#[test]
#[available_gas(2000000000)]
fn test_deploy() {
    // Given
    let owner = contract_address_const::<'OWNER'>();

    // When
    let account_address = deploy(owner);
    let account = AccountABIDispatcher { contract_address: account_address };

    // Then
    assert(account.get_public_key() == owner.into(), 'wrong public key');
}
// #[test]
// #[available_gas(2000000000)]
// fn test_add_keeper() {
//     // Given
//     let owner = contract_address_const::<'OWNER'>();
//     set_contract_address(owner);
//     set_caller_address(owner);

//     // When
//     let account_address = deploy(owner);
//     let swappy_account = ISwappyAccountDispatcher { contract_address: account_address };
//     let account = AccountABIDispatcher { contract_address: account_address };
//     account.get_public_key().print();
//     swappy_account.add_keeper('KEEPER');

//     // Then
//     assert(swappy_account.is_valid_keeper('KEEPER') == true, 'keeper is not valid');
// }


