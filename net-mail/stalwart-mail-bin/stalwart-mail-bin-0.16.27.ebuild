# Copyright 2026 helixnebulatech
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# The release tarball is signed by Stalwart's GitHub Actions release workflow (keyless
# Sigstore). VERIFY_SIG_METHOD must be set before inheriting verify-sig.
VERIFY_SIG_METHOD=sigstore
VERIFY_SIG_CERT_IDENTITY="https://github.com/stalwartlabs/stalwart/.github/workflows/ci.yml@refs/tags/v${PV}"
VERIFY_SIG_CERT_OIDC_ISSUER="https://token.actions.githubusercontent.com"

inherit verify-sig

MY_A="stalwart-x86_64-unknown-linux-musl.tar.gz"
DESCRIPTION="Stalwart mail and collaboration server (official static musl binary)"
HOMEPAGE="https://stalw.art/ https://github.com/stalwartlabs/stalwart"
SRC_URI="
	https://github.com/stalwartlabs/stalwart/releases/download/v${PV}/${MY_A} -> ${P}.tar.gz
	verify-sig? (
		https://github.com/stalwartlabs/stalwart/releases/download/v${PV}/${MY_A}.sigstore.json
			-> ${P}.tar.gz.sigstore
	)
"
S="${WORKDIR}"

# Upstream dual-licenses the server under AGPL-3 and the proprietary Stalwart Enterprise
# License (SELv2); the official release binaries are built with the "enterprise" feature, so
# they contain SELv2 code (inactive without a license key). The rest are the licenses of the
# statically linked Rust crates (same list as net-mail/stalwart-mail).
LICENSE="AGPL-3 Stalwart-SELv2"
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0
	ZLIB BZIP2
"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	acct-group/stalwart-mail
	acct-user/stalwart-mail
	!net-mail/stalwart-mail
"

QA_PREBUILT="usr/bin/stalwart"

src_install() {
	dobin stalwart
	newinitd "${FILESDIR}"/stalwart.initd stalwart
	newconfd "${FILESDIR}"/stalwart.confd stalwart
	insinto /etc/stalwart
	newins "${FILESDIR}"/config.json config.json
	# Owner and mode of /var/lib/stalwart and /var/log/stalwart are set by the init script
	# (checkpath), so the account is not needed at build time.
	keepdir /var/lib/stalwart
}

pkg_postinst() {
	elog "Stalwart 0.16 keeps almost all of its configuration in the database."
	elog "/etc/stalwart/config.json only says where the data store is (RocksDB in"
	elog "/var/lib/stalwart by default). It is owned by root, so the data store cannot be"
	elog "changed from the web admin: edit that file instead."
	elog "With an empty database Stalwart creates default listeners on all addresses."
	elog "Follow the initial setup in https://stalw.art/docs/install/linux before"
	elog "exposing it to the Internet. Its log is in /var/log/stalwart/stalwart.log."
}
