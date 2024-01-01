use serde::Serde;
use starknet::ContractAddress;

#[derive(Drop, Copy, Serde)]
struct Position {
    owner: ContractAddress,
    from: ContractAddress,
    to: ContractAddress,
    amount: u256,
    period: u256,
    last_swap: u256,
    pause: bool
}


#[starknet::interface]
trait IPositionManager<TContractState> {
    fn get_last_id(self: @TContractState) -> u32;
    fn get_position(self: @TContractState, id: u32) -> Position;
    fn create_position(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        amount: u256,
        period: u256
    ) -> u32;
    fn pause_position(ref self: TContractState, id: u32);
    fn resume_position(ref self: TContractState, id: u32);
}

#[starknet::contract]
mod PositionManager {
    use super::ContractAddress;
    use swappy::position::error::PositionError;
    use super::Position;


    #[storage]
    struct Storage {
        last_id: u32,
        owner: LegacyMap<u32, ContractAddress>,
        from: LegacyMap<u32, ContractAddress>,
        to: LegacyMap<u32, ContractAddress>,
        amount: LegacyMap<u32, u256>,
        period: LegacyMap<u32, u256>,
        last_swap: LegacyMap<u32, u256>,
        pause: LegacyMap<u32, bool>
    }
    // *************************************************************************
    //                              CONSTRUCTOR
    // *************************************************************************

    /// Constructor of the contract.
    /// # Arguments
    /// * `owner` - The owner address.
    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) { //self.initialize(owner);
    }

    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    #[external(v0)]
    impl PositionManagerImpl of super::IPositionManager<ContractState> {
        fn get_last_id(self: @ContractState) -> u32 {
            self.last_id.read()
        }

        fn get_position(self: @ContractState, id: u32) -> Position {
            let last_id = self.last_id.read();
            assert(id <= last_id, PositionError::POSITION_NOT_FOUND);

            Position {
                owner: self.owner.read(id),
                from: self.from.read(id),
                to: self.to.read(id),
                amount: self.amount.read(id),
                period: self.period.read(id),
                last_swap: self.last_swap.read(id),
                pause: self.pause.read(id)
            }
        }

        fn create_position(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            amount: u256,
            period: u256
        ) -> u32 {
            let new_id = self.last_id.read() + 1;

            self.owner.write(new_id, starknet::get_caller_address());
            self.from.write(new_id, from);
            self.to.write(new_id, to);
            self.amount.write(new_id, amount);
            self.period.write(new_id, period);
            self.last_swap.write(new_id, 0);
            self.pause.write(new_id, false);

            self.last_id.write(new_id);

            new_id
        }

        fn pause_position(ref self: ContractState, id: u32) {
            let last_id = self.last_id.read();
            assert(id <= last_id, PositionError::POSITION_NOT_FOUND);

            self.pause.write(id, true);
        }

        fn resume_position(ref self: ContractState, id: u32) {
            let last_id = self.last_id.read();
            assert(id <= last_id, PositionError::POSITION_NOT_FOUND);

            self.pause.write(id, false);
        }
    }
}
