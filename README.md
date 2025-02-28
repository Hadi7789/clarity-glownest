# GlowNest
A wellness app for tracking sleep, hydration, and mindfulness on the Stacks blockchain.

## Features
- Track daily sleep metrics (hours, quality)
- Log water intake 
- Record mindfulness sessions
- View historical wellness data
- Earn wellness points for healthy habits

## Setup and Installation
1. Clone the repository
2. Install Clarinet
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to execute test suite

## Usage Examples
```clarity
;; Log sleep data
(contract-call? .glownest log-sleep u8 u80)

;; Record water intake (in ml)
(contract-call? .glownest log-hydration u500)

;; Log mindfulness session
(contract-call? .glownest log-mindfulness u20)

;; Get wellness points
(contract-call? .glownest get-points tx-sender)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
