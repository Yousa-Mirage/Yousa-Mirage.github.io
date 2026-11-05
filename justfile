# Default task: full build
default: build

# Full build (HTML + PDF + assets). Usage: just build [-f/--force]
build *args:
    @uv run build.py build {{ args }}

# Clean the generated _site directory
clean:
    @uv run build.py clean

# Start a local preview server (default port 8000). Use 'just preview 3000' for custom port.
preview port="8000":
    @uv run build.py preview --port {{ port }}

# Commit changes with a custom message
commit message:
    @jj commit -m "{{ message }}"
    @jj bookmark set main -r @-
    @jj git push --bookmark main