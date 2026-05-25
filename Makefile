-include .env

deploy:; forge script script/DeployCrowdFund.s.sol:DeployCrowdFund --rpc-url $(RPC_URL) --account defaultkey --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast