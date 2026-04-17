# Automatic Release System

This project uses an automatic release system that creates GitHub releases after successful tests.

## How it Works

1. **Tests Run First**: On every push to `main`, all tests (ShellCheck, JSON validation) run automatically
2. **Version Bump**: If tests pass, the system analyzes commit messages to determine version bump type
3. **Release Creation**: A new GitHub release is automatically created with changelog and artifacts

## Version Bumping Rules

The system follows [Semantic Versioning](https://semver.org/) and analyzes commit messages:

- **Major** (1.0.0 → 2.0.0): Breaking changes
  - Commits starting with `BREAKING CHANGE:`, `feat!:`, or `fix!:`
  
- **Minor** (1.0.0 → 1.1.0): New features
  - Commits starting with `feat:`
  
- **Patch** (1.0.0 → 1.0.1): Bug fixes and other changes
  - Commits starting with `fix:`, `chore:`, `docs:`, etc.

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>: <description>

[optional body]

[optional footer]
```

### Examples

```bash
# Patch release (1.0.0 → 1.0.1)
git commit -m "fix: correct fan temperature reading"
git commit -m "chore: update dependencies"

# Minor release (1.0.0 → 1.1.0)
git commit -m "feat: add support for multiple displays"
git commit -m "feat: implement module auto-update"

# Major release (1.0.0 → 2.0.0)
git commit -m "feat!: change configuration file format"
git commit -m "BREAKING CHANGE: remove deprecated API endpoints"
```

### Common Types

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring
- `test:` - Test updates
- `perf:` - Performance improvements
- `ci:` - CI/CD changes

## Skipping Release

To prevent a release for documentation-only changes, the workflow ignores:

- Changes to `**.md` files
- Changes in `docs/` directory
- Changes in `.github/` (except workflow files)

To skip CI entirely, add `[skip ci]` to your commit message:

```bash
git commit -m "docs: update README [skip ci]"
```

## Manual Release

If you need to create a release manually:

1. Go to **Actions** → **Create Release**
2. Click **Run workflow**
3. Enter the version number (e.g., `1.2.3`)
4. Click **Run workflow**

## Release Assets

Each release includes:

- `magicmirror-setup-X.Y.Z.tar.gz` - Full installation archive
- `checksums.txt` - SHA256 checksums for verification
- Auto-generated changelog based on commits

## Viewing Releases

All releases are available at:
https://github.com/twicemind/magicmirror-setup/releases
