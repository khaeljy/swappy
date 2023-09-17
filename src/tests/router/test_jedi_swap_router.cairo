// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use starknet::{
    deploy_syscall, get_contract_address, get_caller_address, ContractAddress,
    contract_address_const
};
use starknet::testing::{set_caller_address, set_contract_address, set_account_contract_address};

use debug::PrintTrait;

// Local imports.
use swappy::router::router::{IRouterDispatcher, IRouterDispatcherTrait};
use swappy::router::jedi_swap_router::JediSwapRouter;

// Deploy the contract and return its dispatcher.
fn deploy(owner: ContractAddress) -> IRouterDispatcher {
    // Set up constructor arguments.
    let mut calldata = ArrayTrait::new();
    owner.serialize(ref calldata);

    // Declare and deploy
    let (contract_address, _) = deploy_syscall(
        JediSwapRouter::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    // Return the dispatcher.
    // The dispatcher allows to interact with the contract based on its interface.
    IRouterDispatcher { contract_address }
}

#[test]
#[available_gas(2000000000)]
fn test_deploy() {
    // Given
    let owner = contract_address_const::<12345>();

    // When
    let contract = deploy(owner);

    // Then
    assert(contract.get_owner() == owner, 'wrong owner');
}

#[test]
#[available_gas(2000000000)]
#[should_panic(expected: ('ALREADY_INITIALIZED', 'ENTRYPOINT_FAILED',))]
fn test_initialize_twice() {
    // Given
    let owner = contract_address_const::<12345>();
    let contract = deploy(owner);
    set_contract_address(owner);

    // When
    contract.initialize(contract_address_const::<999999>());
}

#[test]
#[available_gas(2000000000)]
fn test_set_router_address_by_owner() {
    // Given
    let owner = contract_address_const::<12345>();
    let contract = deploy(owner);
    set_contract_address(owner);

    let router_address =
        contract_address_const::<0x02bcc885342ebbcbcd170ae6cafa8a4bed22bb993479f49806e72d96af94c965>();

    // When
    contract.set_router_address(router_address);

    // Then
    assert(contract.get_router_address() == router_address, 'wrong router_address');
}

#[test]
#[available_gas(2000000000)]
#[should_panic(expected: ('ONLY_OWNER', 'ENTRYPOINT_FAILED',))]
fn test_set_router_address_by_non_owner_should_fail() {
    // Given
    let owner = contract_address_const::<12345>();
    let contract = deploy(owner);
    set_contract_address(contract_address_const::<99999>());

    let router_address =
        contract_address_const::<0x02bcc885342ebbcbcd170ae6cafa8a4bed22bb993479f49806e72d96af94c965>();

    // When
    contract.set_router_address(router_address);
}

#[test]
#[available_gas(2000000000)]
fn test_transfert_ownership() {
    // Given
    let owner = contract_address_const::<12345>();
    let contract = deploy(owner);
    set_contract_address(owner);

    // When
    let new_owner = contract_address_const::<99999>();
    contract.transfer_ownership(new_owner);

    // Then
    assert(contract.get_owner() == new_owner, 'transfert_ownership failed');
}

#[test]
#[available_gas(2000000000)]
#[should_panic(expected: ('NOT_IMPLEMENTED', 'ENTRYPOINT_FAILED',))]
fn test_swap_exact_tokens_for_tokens() {
    // Given
    let owner = contract_address_const::<12345>();
    let contract = deploy(owner);
    set_contract_address(owner);

    let router_address =
        contract_address_const::<0x02bcc885342ebbcbcd170ae6cafa8a4bed22bb993479f49806e72d96af94c965>();
    contract.set_router_address(router_address);

    // When
    contract
        .swap_exact_tokens_for_tokens(
            amount_in: 1,
            amount_out_min: 1,
            path: array![contract_address_const::<11111>(), contract_address_const::<22222>()]
                .span(),
            to: owner,
            deadline: 1
        );
}
