# GameTrek
A blockchain-based adventure game built on the Stacks network using Clarity smart contracts.

## Features
- Create unique player characters with customizable attributes
- Explore different game locations and complete quests
- Collect and trade in-game items
- Earn experience points and level up
- Battle system with other players

## Setup and Installation
1. Clone the repository
2. Install Clarinet (if not already installed)
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to run test suite

## Usage Examples
```clarity
;; Create a new player character
(contract-call? .game-trek create-player "Hero1" u100 u80 u70)

;; Move to a new location
(contract-call? .game-trek move-location u1)

;; Start a quest
(contract-call? .game-trek start-quest u1)

;; Battle another player
(contract-call? .game-trek initiate-battle tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
