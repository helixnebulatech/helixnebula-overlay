# Copyright 2026 helixnebulatech
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Standalone implementation of _FORTIFY_SOURCE (up to level 3) for musl"
HOMEPAGE="https://github.com/jvoisin/fortify-headers"
# Upstream tag 3.0.2 is PGP-signed by Julien Voisin (9FCDEE9E1A381F311EA62A7404D041E8171901CC).
# The GitHub tarball of this tag was checked to be identical to the signed tree; the Manifest
# pins its hash. ::gentoo still ships 1.1 from 2019 (bump request: bug #984641).
SRC_URI="https://github.com/jvoisin/fortify-headers/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="0BSD"
SLOT="0"
KEYWORDS="~amd64"
# The default test target uses GCC-only warning flags with -Werror; upstream's "clang"
# target works but needs to run against the system headers, not ${ED}.
RESTRICT="test"

# Headers only: nothing to build.
src_compile() { :; }

src_install() {
	insinto /usr/include/fortify
	doins include/*.h
	insinto /usr/include/fortify/sys
	doins include/sys/*.h
	dodoc README.md
}

pkg_postinst() {
	elog "fortify-headers is only used when its directory is searched before the libc"
	elog "headers and _FORTIFY_SOURCE is defined, e.g. in make.conf:"
	elog "  CFLAGS=\"... -D_FORTIFY_SOURCE=3 -isystem${EPREFIX}/usr/include/fortify\""
	elog "  CXXFLAGS=\"... -D_FORTIFY_SOURCE=3 -isystem${EPREFIX}/usr/include/c++/v1"
	elog "            -isystem${EPREFIX}/usr/include/fortify\""
	elog "(the libc++ path only applies to LLVM profiles; Chimera Linux and Alpine patch"
	elog "their compiler to add it instead). Packages using strip-flags lose it silently."
}
