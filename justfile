# Default task: full build
default: build

# Full build (HTML + PDF + assets). Use 'just build true' for forced rebuild.
build force="":
    @uv run build.py build {{ if force == "true" { "--force" } else { "" } }}

# Build only HTML files. Use 'just html true' for forced rebuild.
html force="":
    @uv run build.py html {{ if force == "true" { "--force" } else { "" } }}

# Build only PDF files. Use 'just pdf true' for forced rebuild.
pdf force="":
    @uv run build.py pdf {{ if force == "true" { "--force" } else { "" } }}

# Only copy static assets
assets:
    @uv run build.py assets

# Clean the generated _site directory
clean:
    @uv run build.py clean

# Start a local preview server (default port 8000). Use 'just preview 3000' for custom port.
preview port="8000":
    @uv run build.py preview --port {{ port }}

# Start preview server without automatically opening the browser
preview-quiet port="8000":
    @uv run build.py preview --port {{ port }} --no-open
