#[starknet::contract]
mod JediSwapRouter {
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************

    // Core lib imports.
    use core::zeroable::Zeroable;
    use starknet::{get_caller_address, ContractAddress};

    // Local imports.
    use swappy::router::router::IRouter;
    use swappy::router::error::RouterError;

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        owner: ContractAddress,
        router_address: ContractAddress
    }

    // *************************************************************************
    //                              CONSTRUCTOR
    // *************************************************************************

    /// Constructor of the contract.
    /// # Arguments
    /// * `owner` - The owner address.
    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.initialize(owner);
    }

    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    #[external(v0)]
    impl JediSwapRouterImpl of IRouter<ContractState> {
        fn initialize(ref self: ContractState, owner: ContractAddress) {
            // Make sure the contract is not already initialized.
            assert(self.owner.read().is_zero(), RouterError::ALREADY_INITIALIZED);

            self.owner.write(owner);
        }

        fn get_owner(ref self: ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            self.only_owner();
            self.owner.write(new_owner);
        }

        fn get_router_address(ref self: ContractState) -> ContractAddress {
            self.router_address.read()
        }

        fn set_router_address(ref self: ContractState, router_address: ContractAddress) {
            self.only_owner();
            self.router_address.write(router_address)
        }

        fn swap_exact_tokens_for_tokens(
            ref self: ContractState,
            amount_in: u256,
            amount_out_min: u256,
            path: Span<ContractAddress>,
            to: ContractAddress,
            deadline: u32
        ) {
            self
                .swap_exact_tokens_for_tokens_internal(
                    amount_in, amount_out_min, path, to, deadline
                );
        }
    }

    #[generate_trait]
    impl JediSwapRouterInternalImpl of JediSwapRouterInternal {
        fn only_owner(self: @ContractState) {
            let sender = get_caller_address();
            let owner = self.owner.read();

            assert(sender == owner, RouterError::ONLY_OWNER);
        }

        fn swap_exact_tokens_for_tokens_internal(
            ref self: ContractState,
            amount_in: u256,
            amount_out_min: u256,
            path: Span<ContractAddress>,
            to: ContractAddress,
            deadline: u32
        ) {
            let router_address = self.router_address.read();
            assert(router_address.is_non_zero(), RouterError::ROUTER_ADDRESS_UNDEFINED);

            // TODO : Call router address swap_exact_tokens_for_tokens
            // Until JediSwap is updated to Cairo 1, panic with 'NOT_IMPLEMENTED'
            panic_with_felt252('NOT_IMPLEMENTED');
        }
    }
}
