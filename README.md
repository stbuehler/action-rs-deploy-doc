# github action: deploy rustdoc to some git repository

Example:

```yaml
jobs:
  doc-nightly:
    name: Rustdoc [nightly]
    runs-on: ubuntu-latest
    needs: build-nightly
    steps:
      - uses: actions/checkout@v2
      - uses: actions-rs/toolchain@v1
        with:
          profile: minimal
          toolchain: nightly
          override: true
      - uses: actions-rs/cargo@v1
        env:
          RUSTDOCFLAGS: "--cfg doc_cfg"
        with:
          command: doc
          args: --all-features
      - uses: stbuehler/action-rs-deploy-doc@v1
        if: ${{ github.event_name == 'push' && github.ref == 'refs/heads/master' }}
        with:
          target: git@github.com:stbuehler/rustdocs
          target-folder: my-crate
          ssh-private-key: ${{ secrets.RUSTDOCS_SSH_ED25519 }}
```

For gh-pages in same repository this might work too:

```yaml
        with:
          target: https://${{ github.token }}@github.com/${{ github.repository }}
          target-folder: .
```

Or any other access token instead of `github.token` with the necessary privileges.
