# Teserakt Github Actions

Set of github actions used for Teserakt CI.

## Private modules handling

Environments `CI_USERNAME` and `CI_ACCESS_TOKEN` are used to allow `go get` to authenticate on private modules repositories. Make sure the user account identified by `CI_USERNAME` have read access to the repository, and set a `CI_ACCESS_TOKEN` secret to a personal access token of this user. It can be created from [Developer settings > Personal access tokens](https://github.com/settings/tokens/new) page, and it require the full `repo` scope.

## go-build

Build a go binary for a given OS/Arch, and report its path. It requires a cmd/<project>/main.go path to exists.

Usage:
```
  build:
    name: Build binaries
    strategy:
      matrix:
        buildOS: [darwin, linux, windows]
        project: [api, cli]
    runs-on: ubuntu-latest
    needs: [test, lint]
    steps:
      - uses: actions/checkout@v1
      - name: Build
        id: build
        uses: github.com/teserakt-io/gh-actions/go-build@master
        env:
          CI_USERNAME: YourCIBotUsername
          CI_ACCESS_TOKEN: ${{ secrets.CI_ACCESS_TOKEN }}
        with:
          project: ${{ matrix.project }}
          goos: ${{ matrix.buildOS }}
          goarch: amd64
```

## go-test

Run go test in current workspace

Usage:
```
  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - uses: github.com/teserakt-io/gh-actions/go-test@master
        env:
          CI_USERNAME: YourCIBotUsername
          CI_ACCESS_TOKEN: ${{ secrets.CI_ACCESS_TOKEN }}
```
