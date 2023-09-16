// *************************************************************************
//                                  IMPORTS
// *************************************************************************

// Core lib imports.
use starknet::ContractAddress;

// *************************************************************************
//                              STRUCTS / CONST
// *************************************************************************

/// @title Represents a call to a target contract
/// @param to The target contract address
/// @param selector The target function selector
/// @param calldata The serialized function parameters
#[derive(Drop, Serde)]
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

// hash of SNIP-6 trait
const SRC6_TRAIT_ID: felt252 =
    1270010605630597976495846281167968799381097569185364931397797212080166453709;

// *************************************************************************
//                  Interfaces of the `Account` contract.
// *************************************************************************
#[starknet::interface]
trait IAccount<TContractState> {
    /// Initialize the contract
    ///
    /// # Arguments
    ///
    /// * `public_key` - The public key allowed to interact with the account
    fn initialize(ref self: TContractState, public_key: felt252);

    /// Execute a transaction through the account
    ///
    /// # Arguments
    ///
    /// * `calls` - The list of calls to execute
    /// @return The list of each call's serialized return value
    fn __execute__(ref self: TContractState, calls: Array<Call>) -> Array<Span<felt252>>;

    /// Assert whether the transaction is valid to be executed
    ///
    /// # Arguments
    ///
    /// * `calls` - The list of calls to validate
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate__(ref self: TContractState, calls: Array<Call>) -> felt252;

    /// Assert whether a given signature for a given hash is valid
    ///
    /// # Arguments
    ///
    /// * `hash` - The hash of the data
    /// * `signature` - The signature to validate
    /// @return The string 'VALID' represented as felt when the signature is valid
    fn is_valid_signature(
        ref self: TContractState, hash: felt252, signature: Array<felt252>
    ) -> felt252;

    /// Query if a contract implements an interface
    ///
    /// # Arguments
    ///
    /// * `interface_id` - The interface identifier, as specified in SRC-5
    /// @return `true` if the contract implements `interface_id`, `false` otherwise
    fn supports_interface(ref self: TContractState, interface_id: felt252) -> bool;

    /// Get the public key
    /// @return The public key
    fn get_public_key(ref self: TContractState) -> felt252;
}

#[starknet::contract]
mod Account {
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************

    // Core lib imports.
    use ecdsa::check_ecdsa_signature;
    use starknet::{get_caller_address, call_contract_syscall, get_tx_info, VALIDATED};

    // Local imports.
    use super::Call;
    use swappy::account::error::AccountError;

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        public_key: felt252
    }

    // *************************************************************************
    //                              CONSTRUCTOR
    // *************************************************************************

    /// Constructor of the contract.
    /// # Arguments
    /// * `public_key` - The public key allowed to interact with the account.
    #[constructor]
    fn constructor(ref self: ContractState, public_key: felt252) {
        self.initialize(public_key);
    }

    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    #[external(v0)]
    impl AccountImpl of super::IAccount<ContractState> {
        fn initialize(ref self: ContractState, public_key: felt252) {
            // Make sure the contract is not already initialized.
            assert(self.public_key.read().is_zero(), AccountError::ALREADY_INITIALIZED);

            self.public_key.write(public_key);
        }

        fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
            self.only_protocol();
            self.execute_multiple_calls(calls)
        }

        fn __validate__(ref self: ContractState, calls: Array<Call>) -> felt252 {
            self.only_protocol();
            self.validate_transaction()
        }

        fn is_valid_signature(
            ref self: ContractState, hash: felt252, signature: Array<felt252>
        ) -> felt252 {
            if self.is_valid_signature_internal(hash, signature.span()) {
                VALIDATED
            } else {
                0
            }
        }

        fn supports_interface(ref self: ContractState, interface_id: felt252) -> bool {
            interface_id == super::SRC6_TRAIT_ID
        }

        fn get_public_key(ref self: ContractState) -> felt252 {
            self.public_key.read()
        }
    }

    #[generate_trait]
    impl AccountInternalImpl of AccountInternal {
        fn only_protocol(self: @ContractState) {
            let sender = get_caller_address();
            assert(sender.is_zero(), AccountError::INVALID_CALLER);
        }

        fn validate_transaction(self: @ContractState) -> felt252 {
            let tx_info = get_tx_info().unbox();
            let tx_hash = tx_info.transaction_hash;
            let signature = tx_info.signature;

            let is_valid = self.is_valid_signature_internal(tx_hash, signature);
            assert(is_valid, AccountError::INVALID_SIGNATURE);

            VALIDATED
        }

        fn is_valid_signature_internal(
            self: @ContractState, hash: felt252, signature: Span<felt252>
        ) -> bool {
            if signature.len() != 2_u32 {
                return false;
            }

            // Verify ECDSA signature
            check_ecdsa_signature(
                message_hash: hash,
                public_key: self.public_key.read(),
                signature_r: *signature[0_u32],
                signature_s: *signature[1_u32]
            )
        }

        fn execute_single_call(self: @ContractState, call: Call) -> Span<felt252> {
            let Call{to, selector, calldata } = call;
            call_contract_syscall(to, selector, calldata.span()).unwrap()
        }

        fn execute_multiple_calls(
            self: @ContractState, mut calls: Array<Call>
        ) -> Array<Span<felt252>> {
            let mut res = ArrayTrait::new();
            loop {
                match calls.pop_front() {
                    Option::Some(call) => {
                        let _res = self.execute_single_call(call);
                        res.append(_res);
                    },
                    Option::None(_) => {
                        break ();
                    },
                };
            };
            res
        }
    }
}
