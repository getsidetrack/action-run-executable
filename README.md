# Run Artifact Executable

A simple action which runs an executable which is stored as a GitHub release artifact. It will unzip, and execute the executable with arguments you provide.

## Inputs

### `repo`

**Required** The name of the person to greet.

### `file`

**Required** The name of the file to extract.

### `path`

**Required** The command to execute. This allows you to specify the executable name, and if necessary, the path to it within the ZIP.

### `ref`

The release to pull the artifact from. This can either be a tag name such as "1.0.0" or "latest". Default `"latest"`.

### `commandArguments`

The arguments which should be provided to the executable.

### `useExecutableExitCode`

Whether or not the exit code of this action should be that of the executable. Default `true`.

For example, if your command returns an exit code of 1 (failure), then this GitHub Action would fail with this enabled.
If this option is disabled, as long as the executable runs, we will return a success exit code.

We will always fail the action if the file could not be downloaded.

## Outputs

### `exitCode`

The exit code returned by the executable.

### `commandOutput`

The raw output returned by the command.

## Example usage

The below example assumes the repository `nicklockwood/SwiftFormat` has a release with an artifact with the name `swiftformat.zip` which contains an executable called `swiftformat` which can be called with no parameters.

```yaml
uses: getsidetrack/action-run-executable@main
with:
  repo: 'nicklockwood/SwiftFormat'
  file: 'swiftformat.zip'
  path: 'swiftformat'
```

The below example assumes the repository `nicklockwood/SwiftFormat` has a release with the tag `0.49.7` with an artifact with the name `swiftformat.zip` which contains an executable called `swiftformat` in the directory called `bin` which can be called with the parameters `--version`.

```yaml
uses: getsidetrack/action-run-executable@main
with:
  repo: 'nicklockwood/SwiftFormat'
  file: 'swiftformat.zip'
  path: 'bin/swiftformat'
  ref: '0.49.7'
  commandArguments: '--version'
```
