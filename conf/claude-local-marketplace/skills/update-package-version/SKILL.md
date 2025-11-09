---
name: update-package-version
description: "This skill should be used when users need to update package versions in nix/pkgs directory with new release information including SHA256 checksums."
---

# Update Package Version

This skill updates package versions in the nix/pkgs directory structure with new release information and checksums.

## When to Use

Use this skill when:
- User requests updating a package to a new version
- New release is available with updated binaries
- Package follows the nix/pkgs directory structure with versions.json and package-specific .nix files

## How to Use

To update a package version, provide:
1. Package name (as used in versions.json)
2. New version number
3. Release manifest URL (for SHA256 checksums)

Example invocation:
"update rust-mcp-filesystem to 0.3.12 using manifest https://github.com/towry/rust-mcp-filesystem/releases/download/v0.3.12/dist-manifest.json"

## Process

1. **Fetch Release Manifest**: Use WebFetch to retrieve the dist-manifest.json from the release URL
2. **Extract Checksums**: Parse the manifest to get SHA256 checksums for each platform/architecture
3. **Update versions.json**: Update the package version in nix/pkgs/versions.json
4. **Update Package .nix**: Update the SHA256 hash(es) in the corresponding package .nix file
5. **Validate Changes**: Confirm all updates are applied correctly

## Expected Directory Structure

```
nix/pkgs/
├── versions.json          # Contains package version mappings
└── {package}.nix        # Package-specific nix expression with SHA256 hashes
```

## File Formats

### versions.json
```json
{
  "package-name": "version.number"
}
```

### Package .nix files
- Use `sha256-map` with platform-specific hashes
- Support platforms: aarch64-darwin, x86_64-darwin, aarch64-linux, x86_64-linux
- Hash format: 64-character SHA256 string

## Validation

- Verify version number follows semantic versioning (x.y.z)
- Confirm SHA256 hashes are valid 64-character hexadecimal strings
- Ensure package exists in both versions.json and has corresponding .nix file
- Check that platform mappings match available binaries in manifest

## Error Handling

If any step fails:
- Report specific error (missing manifest, invalid checksum, file not found)
- Do not proceed with partial updates
- Suggest manual verification steps
