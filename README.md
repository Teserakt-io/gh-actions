# Teserakt Github Actions

Set of github actions used for Teserakt CI.

## Private modules handling

Environments `CI_USERNAME` and `CI_ACCESS_TOKEN` are used to allow `go get` to authenticate on private modules repositories. Make sure the user account identified by `CI_USERNAME` have read access to the repository, and set a `CI_ACCESS_TOKEN` secret to a personal access token of this user. It can be created from [Developer settings > Personal access tokens](https://github.com/settings/tokens/new) page, and it require the full `repo` scope.

## go-build

Build a go binary for a given OS/Arch, and report its path. It requires a cmd/<project>/main.go path to exists.

**Environment variables:**
- `<YOUR_CI_BOT_USERNAME>` is the name of the github account to authenticate with.
- `CI_ACCESS_TOKEN` is a secret to be created, containing an access token with `repo` scope

**Inputs:**
- `<LIST_OF_YOUR_BINARIES>` is the list of binaries to be built. They must be sub folders, under a `./cmd/` folder, containing go file(s) with a main function.

**Usage:**
```
  build:
    name: Build binaries
    strategy:
      matrix:
        buildOS: [darwin, linux, windows]
        project: [<LIST_OF_YOUR_BINARIES>]
    runs-on: ubuntu-latest
    needs: [test, lint]
    steps:
      - uses: actions/checkout@v1
      - name: Build
        id: build
        uses: github.com/teserakt-io/gh-actions/go-build@master
        env:
          CI_USERNAME: "<YOUR_CI_BOT_USERNAME>"
          CI_ACCESS_TOKEN: ${{ secrets.CI_ACCESS_TOKEN }}
        with:
          project: ${{ matrix.project }}
          goos: ${{ matrix.buildOS }}
          goarch: amd64
```

## go-test

Run go test in current workspace

**Environment variables:**
- `<YOUR_CI_BOT_USERNAME>` is the name of the github account to authenticate with.
- `CI_ACCESS_TOKEN` is a secret to be created, containing an access token with `repo` scope

**Usage:**
```
  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - uses: github.com/teserakt-io/gh-actions/go-test@master
        env:
          CI_USERNAME: "<YOUR_CI_BOT_USERNAME>"
          CI_ACCESS_TOKEN: ${{ secrets.CI_ACCESS_TOKEN }}
```

## docker-build

Build docker images and push them to a private google cloud registry.

It will push multiple tagged for the image:
- one with the short commit hash.
- one with the branch name (or latest when ran from `master` branch), or the tag name if the commit is tagged.

It needs to be placed after a go-build action to reuse the output binary.

**Inputs:**
- `<YOUR_IMAGE_NAME>` must be set to the image name to be built.
- `<YOUR_REGISTRY>` must be set to the ID of a google cloud registry.
- `<YOUR_REGISTRY_ENDPOINT>` must be set to the registry uri, ie `eu.gcr.io`
- `GCR_TOKEN` must be created as a secret variable, containing a private key from a google cloud service account, having proper permissions on the registry.

**Usage:**
```
    steps:
      - uses: github.com/teserakt-io/gh-actions/docker-build@master
        if: matrix.buildOS == 'linux' # Only build image for linux
        with:
          branch: ${{ github.ref }}
          binary_path: ./${{ steps.build.outputs.binary-path }}
          image_name: "<YOUR_IMAGE_NAME>"
          registry_endpoint: "<YOUR_REGISTRY_ENDPOINT>"
          registry_name: "<YOUR_REGISTRY>"
          registry_username: _json_key
          registry_password: ${{ secrets.GCR_TOKEN }}
```
