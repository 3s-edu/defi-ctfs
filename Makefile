-include .env

all: remove install update clean build

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add .

# Install dependencies
install :; forge install foundry-rs/forge-std --no-commit && forge install openzeppelin/openzeppelin-contracts --no-commit && forge install openzeppelin/openzeppelin-contracts-upgradeable --no-commit && forge install safe-global/safe-contracts@main --no-commit

# Update dependencies
update :; forge update

# Clean artifacts
clean :; forge cl

# Build the project
build :; forge build && FOUNDRY_PROFILE=0_6_x forge build

# Run tests
tests :; forge test

snapshot :; forge snapshot