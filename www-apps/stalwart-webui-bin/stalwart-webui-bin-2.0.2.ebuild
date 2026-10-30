# Copyright 2026 helixnebulatech
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Web administration panel for the Stalwart mail server (prebuilt)"
HOMEPAGE="https://github.com/stalwartlabs/webui"
# No signature or attestation on GitHub: the Manifest hash is the one from the GitHub API
# (sha256 959f8e7172bcd7e8fd75d1ed1b7e66c53f80119f2bdb22dcad1cf38b92905ddf, checked 2026-10-30).
# Stalwart reads it from disk (Application.resourceUrl = file://...): it never downloads it itself.
SRC_URI="https://github.com/stalwartlabs/webui/releases/download/v${PV}/webui.zip -> ${P}.zip"
S="${WORKDIR}"

# Upstream dual-licenses the panel under AGPL-3 and the proprietary Stalwart Enterprise
# License (SELv2); the prebuilt bundle includes both.
LICENSE="AGPL-3 Stalwart-SELv2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

# Not unpacked: Stalwart reads the zip itself, so app-arch/unzip is not needed
# (pkgcheck reports MissingUnpackerDep; it does not apply here).
src_unpack() { :; }

src_install() {
	insinto /usr/share/stalwart
	newins "${DISTDIR}/${P}.zip" "webui-${PV}.zip"
}
