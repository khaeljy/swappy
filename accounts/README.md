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



starkli declare target/dev/swappy_JediSwapRouter.contract_class.json --account accounts/deployer.json
# 0x05fee938faa73a65d7f5c27dab214548c7e0fb66a206285af4aa9ea81aabb6b6

starkli deploy 0x05fee938faa73a65d7f5c27dab214548c7e0fb66a206285af4aa9ea81aabb6b6 0x45dfe51e70f6efe25242faab81f2b1378b333430073634e2dff852bba8b4cf4 --account accounts/deployer.json
# 0x01f828e763969869065a9151a65ea84f9eeac968bb2a44481abffedf374a2885

starkli invoke 0x01f828e763969869065a9151a65ea84f9eeac968bb2a44481abffedf374a2885 set_router_address 0x02bcc885342ebbcbcd170ae6cafa8a4bed22bb993479f49806e72d96af94c965 --account accounts/deployer.json --log-traffic


starkli invoke 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 approve 0x01f828e763969869065a9151a65ea84f9eeac968bb2a44481abffedf374a2885 u256:1000000000 --account accounts/deployer.json --log-traffic
starkli invoke 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 approve 0x02bcc885342ebbcbcd170ae6cafa8a4bed22bb993479f49806e72d96af94c965 u256:1000000000 --account accounts/deployer.json --log-traffic

starkli invoke 0x01f828e763969869065a9151a65ea84f9eeac968bb2a44481abffedf374a2885 swap_exact_tokens_for_tokens u256:1000 u256:0 2 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 0x03e85bfbb8e2a42b7bead9e88e9a1b19dbccf661471061807292120462396ec9 0x060600c10cf5995af0034f22011184aa69f3e77818e9372a279b86b5ffb5efd2 2704146400 --account accounts/deployer.json --log-traffic



starkli invoke 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 approve 0x039ff68beaea3cb565ae7fa929974b64199fb7725cbd9adabd9a3a5f32636ec7 u256:1000000000 --account accounts/deployer.json --log-traffic

starkli invoke 0x039ff68beaea3cb565ae7fa929974b64199fb7725cbd9adabd9a3a5f32636ec7 swap_exact_tokens_for_tokens u256:1000 u256:0 2 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 0x03e85bfbb8e2a42b7bead9e88e9a1b19dbccf661471061807292120462396ec9 0x060600c10cf5995af0034f22011184aa69f3e77818e9372a279b86b5ffb5efd2 1704146400 --account accounts/deployer.json --log-traffic