use swappy::position::position_manager::IPositionManagerDispatcherTrait;
use core::traits::Into;
use debug::PrintTrait;
use starknet::{
    deploy_syscall, get_contract_address, get_caller_address, ContractAddress,
    contract_address_const
};
use starknet::testing::{set_caller_address, set_contract_address, set_account_contract_address};

use swappy::position::position_manager::{PositionManager, IPositionManagerDispatcher};


fn deploy(owner: ContractAddress) -> IPositionManagerDispatcher {
    // Set up constructor arguments.AccountABIDispatcher
    let mut calldata = ArrayTrait::new();
    owner.serialize(ref calldata);

    // Declare and deploy
    let (contract_address, _) = deploy_syscall(
        PositionManager::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    // Return the dispatcher.
    // The dispatcher allows to interact with the contract based on its interface.
    IPositionManagerDispatcher { contract_address }
}

#[test]
#[available_gas(2000000000)]
fn test_create_position() {
    // Given
    let owner = contract_address_const::<'OWNER'>();
    let contract = deploy(owner);
    set_contract_address(owner);

    // When
    let position_id = contract
        .create_position(
            contract_address_const::<'FROM_TOKEN'>(), contract_address_const::<'TO_TOKEN'>(), 1, 60
        );

    // Then
    let position = contract.get_position(position_id);
    assert(position_id == 1, 'wrong position_id');
    assert(position.owner == owner, 'wrong owner');
    assert(position.from == contract_address_const::<'FROM_TOKEN'>(), 'wrong FROM token');
    assert(position.to == contract_address_const::<'TO_TOKEN'>(), 'wrong TO token');
    assert(position.amount == 1, 'wrong amount');
    assert(position.period == 60, 'wrong period');
    assert(position.pause == false, 'wrong pause value');
    assert(position.last_swap == 0, 'wrong last_swap value');
}

#[test]
#[available_gas(2000000000)]
fn test_pause_position() {
    // Given
    let owner = contract_address_const::<'OWNER'>();
    let contract = deploy(owner);
    set_contract_address(owner);

    // When
    let position_id = contract
        .create_position(
            contract_address_const::<'FROM_TOKEN'>(), contract_address_const::<'TO_TOKEN'>(), 1, 60
        );
    contract.pause_position(position_id);

    // Then
    let position = contract.get_position(position_id);
    assert(position_id == 1, 'wrong position_id');
    assert(position.owner == owner, 'wrong owner');
    assert(position.from == contract_address_const::<'FROM_TOKEN'>(), 'wrong FROM token');
    assert(position.to == contract_address_const::<'TO_TOKEN'>(), 'wrong TO token');
    assert(position.amount == 1, 'wrong amount');
    assert(position.period == 60, 'wrong period');
    assert(position.pause == true, 'wrong pause value');
    assert(position.last_swap == 0, 'wrong last_swap value');
}

#[test]
#[available_gas(2000000000)]
#[should_panic(expected: ('Position: not authorized', 'ENTRYPOINT_FAILED',))]
fn test_pause_position_should_fail() {
    // Given
    let owner = contract_address_const::<'OWNER'>();
    let contract = deploy(owner);
    set_contract_address(owner);

    // When
    let position_id = contract
        .create_position(
            contract_address_const::<'FROM_TOKEN'>(), contract_address_const::<'TO_TOKEN'>(), 1, 60
        );

    set_contract_address(contract_address_const::<'OTHER'>());
    contract.pause_position(position_id);
}

#[test]
#[available_gas(2000000000)]
#[should_panic(expected: ('Position: not authorized', 'ENTRYPOINT_FAILED',))]
fn test_resume_position_should_fail() {
    // Given
    let owner = contract_address_const::<'OWNER'>();
    let contract = deploy(owner);
    set_contract_address(owner);

    // When
    let position_id = contract
        .create_position(
            contract_address_const::<'FROM_TOKEN'>(), contract_address_const::<'TO_TOKEN'>(), 1, 60
        );

    set_contract_address(contract_address_const::<'OTHER'>());
    contract.resume_position(position_id);
}

#[test]
#[available_gas(2000000000)]
fn test_pause_then_resume_position() {
    // Given
    let owner = contract_address_const::<'OWNER'>();
    let contract = deploy(owner);
    set_contract_address(owner);

    // When
    let position_id = contract
        .create_position(
            contract_address_const::<'FROM_TOKEN'>(), contract_address_const::<'TO_TOKEN'>(), 1, 60
        );
    contract.pause_position(position_id);

    // Then
    let position = contract.get_position(position_id);
    assert(position_id == 1, 'wrong position_id');
    assert(position.owner == owner, 'wrong owner');
    assert(position.from == contract_address_const::<'FROM_TOKEN'>(), 'wrong FROM token');
    assert(position.to == contract_address_const::<'TO_TOKEN'>(), 'wrong TO token');
    assert(position.amount == 1, 'wrong amount');
    assert(position.period == 60, 'wrong period');
    assert(position.pause == true, 'wrong pause value');
    assert(position.last_swap == 0, 'wrong last_swap value');

    // When
    contract.resume_position(position_id);

    // Then
    let position = contract.get_position(position_id);
    assert(position_id == 1, 'wrong position_id');
    assert(position.owner == owner, 'wrong owner');
    assert(position.from == contract_address_const::<'FROM_TOKEN'>(), 'wrong FROM token');
    assert(position.to == contract_address_const::<'TO_TOKEN'>(), 'wrong TO token');
    assert(position.amount == 1, 'wrong amount');
    assert(position.period == 60, 'wrong period');
    assert(position.pause == false, 'wrong pause value');
    assert(position.last_swap == 0, 'wrong last_swap value');
}
