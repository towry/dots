# Bruno CLI Usage Reference

```bash
bru run [options] [files/folders]
```

## Essential Options

### Environment & Data
- `--env [string]` - Specify environment to run with
- `--env-var [string]` - Overwrite environment variable (repeatable)
- `--env-file [string]` - Path to environment file (.bru or .json)
- `--sandbox [string]` - JavaScript sandbox: "developer" (default) or "safe"
- `--csv-file-path` - CSV file to run collection with
- `--json-file-path` - Path to JSON data file
- `--iteration-count [number]` - Number of times to run collection
- `-r` - Recursive run

### Request Control
- `--delay [number]` - Delay between requests (milliseconds)
- `--tests-only` - Only run requests with tests
- `--bail` - Stop on first failure
- `--tags [string]` - Run only requests with ALL specified tags
- `--exclude-tags [string]` - Skip requests with ANY specified tags
- `--parallel` - Run requests in parallel

### Security
- `--cacert [string]` - CA certificate to verify peer against
- `--client-cert-config` - Path to client certificate config
- `--insecure` - Allow insecure server connections
- `--disable-cookies` - Disable automatic cookie handling
- `--noproxy` - Disable all proxy settings

### Reporting
- `--reporter-json [string]` - Generate JSON report
- `--reporter-junit [string]` - Generate JUnit report
- `--reporter-html [string]` - Generate HTML report

### Import
- `--source [string]` - Path to OpenAPI specification
- `--output-file [string]` - Output Bruno collection file
- `--collection-name [string]` - Name for imported collection

## Common Examples

```bash
# Run with environment
bru run --env production

# Run tests only with delay
bru run --tests-only --delay 1000

# Run specific tags in parallel
bru run --tags smoke,api --parallel

# Generate HTML report
bru run --reporter-html report.html

# Import OpenAPI
bru run --source openapi.yaml --output-file collection.json --collection-name "My API"
```
