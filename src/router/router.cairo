// *************************************************************************
//                                  IMPORTS
// *************************************************************************
use starknet::ContractAddress;

// *************************************************************************
//                              STRUCTS / CONST
// *************************************************************************

// *************************************************************************
//                  Interfaces of the `Router` contract.
// *************************************************************************
#[starknet::interface]
trait IRouter<TContractState> {
    /// Initialize the contract
    ///
    /// # Arguments
    ///
    /// * `owner` - The contract owner address
    fn initialize(ref self: TContractState, owner: ContractAddress);

    /// Get the owner address
    fn get_owner(ref self: TContractState) -> ContractAddress;

    /// Transfer the ownership
    ///
    /// # Arguments
    ///
    /// * `new_owner` - The new owner address
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);

    /// Get the router address
    fn get_router_address(ref self: TContractState) -> ContractAddress;

    /// Set the router address
    ///
    /// # Arguments
    ///
    /// * `router_address` - The router address
    fn set_router_address(ref self: TContractState, router_address: ContractAddress);

    /// Swap exact tokens for tokens
    ///
    /// # Arguments
    ///
    /// * `amount_in` - Amount of token to swap
    /// * `amount_out_min` - Min out token amount
    /// * `path` - Route path
    /// * `to` - The recipient of swap
    /// * `deadline` - The deadline of the swap transaction
    fn swap_exact_tokens_for_tokens(
        ref self: TContractState,
        amount_in: u256,
        amount_out_min: u256,
        path: Span<felt252>,
        to: felt252,
        deadline: felt252
    );
}
