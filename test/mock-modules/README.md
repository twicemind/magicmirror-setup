# Mock Modules Directory

This directory simulates the MagicMirror modules directory for testing.

## Adding Test Modules

Create a directory with a name starting with `MMM-`:

```bash
mkdir -p MMM-TestModule
cd MMM-TestModule
echo '{"name": "MMM-TestModule", "version": "1.0.0"}' > package.json
```

## Structure

Each module should have at minimum:
- A directory name starting with `MMM-`
- (Optional) A `package.json` file
- (Optional) A `.git` directory (for git-based modules)
