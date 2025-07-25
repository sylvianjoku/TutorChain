# TutorChain

A decentralized academic tutoring session tracking and recognition platform for incentivizing educational support on Stacks blockchain.

## Features

- Tutoring hour tracking with subject-based validation
- Academic tutor recognition and reward system
- Subject approval and management system
- Contribution-based recognition point calculation
- Comprehensive tutoring program statistics

## Smart Contract Functions

### Public Functions
- `launch-tutoring-program` - Initialize tutoring tracking program
- `approve-subject` - Approve subject for tracking (coordinator only)
- `log-tutoring-hours` - Register tutoring hours with subject
- `calculate-recognition-points` - Calculate recognition points (coordinator only)
- `claim-tutoring-recognition` - Claim tutoring recognition rewards

### Read-Only Functions
- `get-tutoring-hours` - Get tutor's total hours
- `get-tutor-subject` - Get tutor's subject specialization
- `get-total-tutoring-hours` - Get total program hours
- `is-subject-approved` - Check subject approval status
- `get-program-stats` - Get comprehensive program statistics

## Subjects
Mathematics, Science, English, History, Computer Science, Languages, etc.

## Usage

Deploy the contract to create a tutoring tracking system where educators can log tutoring hours, earn recognition, and contribute to academic support initiatives.

## License

MIT