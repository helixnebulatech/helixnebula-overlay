# helixnebula overlay

Gentoo ebuild repository maintained by [helixnebulatech](https://github.com/helixnebulatech).
It focuses on hardening (musl and LLVM profiles first) and on the Stalwart mail server.

## Packages

| Package | Description |
|---|---|
| `sys-libs/hardened_malloc` | GrapheneOS's hardened memory allocator. `USE=cxx` (default) also replaces C++ `new`/`delete`. |
| `sys-libs/fortify-headers` | jvoisin's `_FORTIFY_SOURCE` implementation for musl, version 3.x (`::gentoo` still has 1.1). |
| `net-mail/stalwart-mail-bin` | Official static musl binary of Stalwart, verified with its Sigstore signature. Alternative to `net-mail/stalwart-mail` (built from source). |
| `www-apps/stalwart-webui-bin` | Stalwart's prebuilt web admin panel, pinned, to serve it from disk. |
| `net-mail/stalwart-spam-rules` | Stalwart's spam filter rules, pinned, to load them from disk. |

All ebuilds are `~amd64`. Services ship OpenRC init scripts only (no systemd units).

## Usage

```sh
eselect repository add helixnebula git https://github.com/helixnebulatech/helixnebula-overlay.git
emaint sync -r helixnebula
```

Then accept the keywords of the packages you want, for example in
`/etc/portage/package.accept_keywords/helixnebula`:

```
sys-libs/hardened_malloc::helixnebula ~amd64
```

### Licenses

Stalwart's official binary and web panel include code under the proprietary Stalwart
Enterprise License (SELv2), which is inactive without a license key. Its text is in
`licenses/Stalwart-SELv2`. Portage asks you to accept it, e.g. in `/etc/portage/package.license`:

```
net-mail/stalwart-mail-bin Stalwart-SELv2
www-apps/stalwart-webui-bin Stalwart-SELv2
```

## Verification

- `hardened_malloc`: GrapheneOS signs its tags with an SSH key. `fortify-headers`: the tag is
  PGP-signed by its author. In both cases the GitHub tarball was checked to be identical to the
  signed tree before its hash was pinned in the `Manifest`.
- `stalwart-mail-bin`: checked at build time with `verify-sig` (Sigstore, Stalwart's GitHub
  release workflow as the identity).
- `stalwart-webui-bin`, `stalwart-spam-rules`: no upstream signature; the `Manifest` hash matches
  the one published by the GitHub API for the release asset.

All ebuilds pass `pkgcheck scan`, except for two expected notes: `fortify-headers` overrides the
package from `::gentoo`, and `stalwart-webui-bin` installs its zip without unpacking it.

## License

The ebuilds and other files in this repository are distributed under the GNU General Public
License v2 (see `LICENSE`), like the Gentoo repository. Each package keeps its own upstream
license, listed in its ebuild.
