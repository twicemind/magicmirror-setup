# Test Environment

This directory contains files for local testing of the MagicMirror Setup project.

## Structure

```
test/
├── docker-compose.yml       # Docker Compose setup for testing
├── mock-modules/           # Mock modules directory
├── mock-config/            # Mock configuration directory
└── README.md              # This file
```

## Usage

1. Start the test environment:
   ```bash
   docker-compose up -d
   ```

2. Access the WebUI:
   ```
   http://localhost:8080
   ```

3. View logs:
   ```bash
   docker-compose logs -f
   ```

4. Stop the environment:
   ```bash
   docker-compose down
   ```

## Mock Data

The test environment uses mock directories to simulate the MagicMirror installation:

- `mock-modules/`: Simulates `/opt/mm/mounts/modules`
- `mock-config/`: Simulates `/opt/mm/mounts/config`

You can add test data to these directories to test the WebUI functionality.

## Testing Scenarios

### 1. Module Management
- Add a fake module directory to `mock-modules/`
- Test installation and removal via WebUI

### 2. Configuration Editor
- Add a test config.json to `mock-config/`
- Test editing via WebUI

### 3. API Endpoints
- Test all API endpoints with curl or Postman
- Verify responses

## Notes

- This is a development/testing environment only
- Some features (like OS updates) cannot be fully tested in containers
- Scripts are mounted read-only to prevent accidental modifications
