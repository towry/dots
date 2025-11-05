{
  version ? "0.0.1",
  pkgs ? (import <nixpkgs> { }),
  fastuuid ? null,
}:
let
  pname = "litellm";
in
with pkgs;
python3Packages.buildPythonPackage {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/towry/litellm/releases/download/nix-build-v${version}/litellm-minimal-${version}.tar.gz";
    sha256 = "sha256-nFJmB9HxbETOuoyV5Y0a4WURXOpJA4XA+USUbq6SvBg=";
  };

  # Use pyproject.toml for build configuration
  format = "pyproject";

  # The tarball extracts to current directory with multiple subdirectories
  sourceRoot = ".";

  # Patch to replace fastuuid with standard uuid module
  postPatch = ''
        # Replace fastuuid import with standard uuid in _uuid.py
        if [ -f litellm/_uuid.py ]; then
          cat > litellm/_uuid.py << 'EOF'
    """
    Internal unified UUID helper.

    Fallback to standard uuid when fastuuid is not available.
    """

    import uuid as _uuid


    # Expose a module-like alias so callers can use: uuid.uuid4()
    uuid = _uuid


    def uuid4():
        """Return a UUID4 using the selected backend."""
        return uuid.uuid4()
    EOF
        fi
  '';

  # Build dependencies
  nativeBuildInputs = [
    python3Packages.poetry-core
  ];

  # Runtime dependencies - minimal set for proxy mode
  propagatedBuildInputs =
    (with python3Packages; [
      # Core dependencies
      httpx
      openai
      python-dotenv
      tiktoken
      importlib-metadata
      tokenizers
      click
      jinja2
      aiohttp
      pydantic
      jsonschema
      requests

      # Proxy dependencies (from [tool.poetry.extras] proxy)
      fastapi
      fastapi-sso
      uvicorn
      uvloop
      gunicorn
      backoff
      pyyaml
      rq
      orjson
      apscheduler
      pyjwt
      python-multipart
      email-validator
      cryptography
      pynacl
      websockets
      boto3
      rich

      # Proxy extras dependencies
      prisma
      pytz

      # SOCKS proxy support
      socksio
    ])
    ++ lib.optionals (fastuuid != null) [ fastuuid ]; # Don't run tests during build (they require network access)
  doCheck = false;

  # Disable runtime dependency checking AND import checking - fastuuid causes circular deps
  dontCheckRuntimeDeps = true;
  pythonImportsCheck = [ ]; # Disabled - would fail due to fastuuid

  # Install proxy extras by default
  postInstall = ''
    # Ensure litellm-proxy-extras is available
    if [ -d "$out/${python3Packages.python.sitePackages}/litellm-proxy-extras" ]; then
      echo "✓ litellm-proxy-extras installed"
    fi
  '';

  meta = with lib; {
    description = "Call all LLM APIs using the OpenAI format";
    homepage = "https://github.com/BerriAI/litellm";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ ];
    mainProgram = "litellm";
  };

  # Disable some security hardening that might interfere with Python packages
  dontStrip = true;
}
