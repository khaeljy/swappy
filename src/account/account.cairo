#[starknet::contract]
mod Account {
    use core::array::ArrayTrait;
    use openzeppelin::account::interface::ISRC6;
    use openzeppelin::account::AccountComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    use starknet::account::Call;
    use starknet::{get_tx_info, ContractAddress, contract_address_const};

    component!(path: AccountComponent, storage: account, event: AccountEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // Account
    #[abi(embed_v0)]
    impl SRC6CamelOnlyImpl = AccountComponent::SRC6CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl PublicKeyImpl = AccountComponent::PublicKeyImpl<ContractState>;
    #[abi(embed_v0)]
    impl PublicKeyCamelImpl = AccountComponent::PublicKeyCamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl DeclarerImpl = AccountComponent::DeclarerImpl<ContractState>;
    #[abi(embed_v0)]
    impl DeployableImpl = AccountComponent::DeployableImpl<ContractState>;

    impl AccountInternalImpl = AccountComponent::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        account: AccountComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        AccountEvent: AccountComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, public_key: felt252) {
        self.account.initializer(public_key);
    }

    /// Executes a list of calls from the account.
    #[external(v0)]
    fn __execute__(self: @ContractState, mut calls: Array<Call>) -> Array<Span<felt252>> {
        self.account.__execute__(calls)
    }

    /// Verifies the validity of the signature for the current transaction.
    /// This function is used by the protocol to verify `invoke` transactions.
    #[external(v0)]
    fn __validate__(self: @ContractState, mut calls: Array<Call>) -> felt252 {
        let tx_info = get_tx_info().unbox();
        let tx_hash = tx_info.transaction_hash;
        let signature = tx_info.signature;

        if !self.account._is_valid_signature(tx_hash, signature) {
            loop {
                match calls.pop_front() {
                    Option::Some(call) => {

                        // TODO: Add whitelist for contracts allowed and selectors
                        assert(
                            call
                                .to == contract_address_const::<
                                    0x0097ab8a6dc7760a687caaffa7101611b20babda533ce40b3cac94fb1926355e
                                >(),
                            'UNAUTHORIZED CONTRACT'
                        );
                    },
                    Option::None(_) => { break (); },
                };
            };
        }

        starknet::VALIDATED
    }

    /// Verifies that the given signature is valid for the given hash.
    #[external(v0)]
    fn is_valid_signature(
        self: @ContractState, hash: felt252, signature: Array<felt252>
    ) -> felt252 {
        if self.account._is_valid_signature(hash, signature.span()) {
            starknet::VALIDATED
        } else {
            0
        }
    }
}
