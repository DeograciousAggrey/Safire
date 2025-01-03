source .env
export RPC_URL=$BASE_SEPOLIA_RPC_URL
export SCAN_URL=$BASE_SEPOLIA_SCAN_URL
export SCAN_API_KEY=$BASE_SEPOLIA_SCAN_API_KEY

forge script script/deploy/DeploySimpleCondition.s.sol --rpc-url $RPC_URL --verifier-url $EXPLORER_URL --etherscan-api-key $EXPLORER_API_KEY --broadcast --verify
