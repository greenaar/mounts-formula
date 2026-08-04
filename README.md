# mounts

Manages filesystem mounts and `/etc/fstab` entries from pillar, with an
optional helper to format a block device with ext4 before mounting it if
it isn't already formatted.

## Availability

Debian and Ubuntu only.

## Usage

```yaml
include:
  - mounts
```

## Configuration

All configuration lives under the `mounts` pillar key. See
`pillar.example` for a full example.

| Section     | Description                                                          |
|--------------|------------------------------------------------------------------------|
| `mounted`    | Dict of `mount.mounted` entries, keyed by an arbitrary state ID        |
| `unmounted`  | Dict of `mount.unmounted` entries, keyed by an arbitrary state ID      |

Each entry under `mounted` accepts: `name`, `device`, `fstype` (default
`ext4`), `format` (bool, runs the safe-format helper first), `mkmnt`,
`opts`, `hidden_opts`, `dump`, `pass_num`, `config`, `persist`, `mount`,
`user`, `match_on`.

Each entry under `unmounted` accepts: `name`, `device`, `config`,
`persist`, `user`.

## Notes / audit findings

* **Bug fix:** the `format` branch's `require_in` was missing its list
  dash (`- mount: ...` instead of a bare `mount: ...` mapping), which is
  invalid for a requisite list. Fixed.
* `format: true` uses a bundled `safe-format` script rather than Salt's
  built-in `blockdev.formatted` state, to avoid a long-standing issue
  where `mkfs` would hang waiting for interactive confirmation on
  already-formatted disks (saltstack/salt#31033). If your Salt version
  has this fixed, `blockdev.formatted` may now be a simpler native
  alternative -- not switched here since it wasn't possible to verify
  behavior against your specific Salt version.
* The `safe-format` script only supports ext4. Extending it (or adding a
  `fstype` argument) would be needed to format devices with other
  filesystems.
* Swap is not currently supported by this formula; add a `mounts:swap`
  section (fstab entry + `swapon`) if you need it.

## Relationship to upstream

**This is a heavily modified fork of
[`saltstack-formulas/mounts-formula`](https://github.com/saltstack-formulas/mounts-formula). Do not treat it as a drop-in
replacement for it.**

States have been renamed, split, merged, and removed; pillar keys have moved;
defaults differ; and behaviour has changed in ways that are not backward
compatible. Pointing an existing deployment at this formula without reading
`pillar.example` and the state list above will not do what you expect.

It is also not a newer version of upstream — it diverged and was maintained
separately, so upstream may well have fixes and platform support that this
does not. If you want the maintained original, use
[`saltstack-formulas/mounts-formula`](https://github.com/saltstack-formulas/mounts-formula).

### Credit

The foundation of this formula, and much of what still works well in it, is
the work of the [saltstack-formulas](https://github.com/saltstack-formulas) authors and contributors. Any
bugs introduced in the divergence are this fork's own.

## License

Dedicated to the public domain under [CC0 1.0 Universal](LICENSE).
