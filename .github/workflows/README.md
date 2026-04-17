# GitHub Actions Workflows

This directory contains automated CI/CD workflows for the MagicMirror Setup project.

## Available Workflows

### 1. release.yml
- **Trigger**: Manual dispatch or push to main branch with version tags
- **Purpose**: Create GitHub releases with automatic versioning
- **Actions**:
  - Creates release archives
  - Generates changelog
  - Publishes release assets

### 2. test.yml
- **Trigger**: Pull requests and pushes to main
- **Purpose**: Run automated tests
- **Actions**:
  - Syntax validation
  - Shell script linting (shellcheck)
  - Python code validation
  - Docker container tests

### 3. version-bump.yml
- **Trigger**: Manual dispatch
- **Purpose**: Bump version numbers
- **Actions**:
  - Updates version in files
  - Creates git tag
  - Pushes changes

## Usage

All workflows are configured to run automatically or can be triggered manually from the GitHub Actions tab.
