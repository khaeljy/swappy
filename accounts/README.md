# Create a new signer
```
starkli signer keystore new accounts/keystore.json
export STARKNET_KEYSTORE=accounts/keystore.json
```

# Create the deployer account
```
starkli account oz init accounts/deployer.json
starkli account deploy accounts/deployer.json
```

# Declare Swappy Account Contract
```
starkli declare target/dev/swappy_Account.contract_class.json --account accounts/deployer.json
# 0x03dd8bbd25d0807d830cc78f3aef5e759c186c8f91efe1fcf3531132fdcade4b
```

# Create a swappy account
```
starkli account oz init accounts/swappy.json
```
> update class_hash
```
starkli account deploy accounts/swappy.json
```

# Deploy Position Manager Contract
```
starkli declare target/dev/swappy_PositionManager.contract_class.json --account accounts/deployer.json
# 0x0303b3c6adfb5015a09bce62b23428bb3e3b4bca3726a27919ae78763b5e993a

starkli deploy 0x0303b3c6adfb5015a09bce62b23428bb3e3b4bca3726a27919ae78763b5e993a 0x0 --account accounts/deployer.json
# 0x0097ab8a6dc7760a687caaffa7101611b20babda533ce40b3cac94fb1926355e
```

# Get last position ID
```
starkli call 0x0097ab8a6dc7760a687caaffa7101611b20babda533ce40b3cac94fb1926355e get_last_id
```

# create position
```
starkli invoke 0x0097ab8a6dc7760a687caaffa7101611b20babda533ce40b3cac94fb1926355e create_position 0x1 0x2 u256:1 u256:1 --account accounts/swappy.json
```

# Pause position
```
starkli invoke 0x0097ab8a6dc7760a687caaffa7101611b20babda533ce40b3cac94fb1926355e pause_position [POSITION_ID] --account accounts/swappy.json
```

# Resume position
```
starkli invoke 0x0097ab8a6dc7760a687caaffa7101611b20babda533ce40b3cac94fb1926355e resume_position [POSITION_ID] --account accounts/swappy.json
```