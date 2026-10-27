# Copyright 2026 helixnebulatech
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Spam filter rules for the Stalwart mail server"
HOMEPAGE="https://github.com/stalwartlabs/spam-filter"
# Manifest hash = the one from the GitHub API (sha256
# 1d3a66f6fa9a32f711c5b3a73853663eff27c994a46e8f6a0db64a9b2a580f52, checked 2026-10-25).
# Stalwart imports them from disk (SpamSettings.spamFilterRulesUrl = file://...).
SRC_URI="https://github.com/stalwartlabs/spam-filter/releases/download/v${PV}/spam-filter-rules.json.gz -> ${P}.json.gz"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

src_unpack() { :; }

src_install() {
	insinto /usr/share/stalwart
	newins "${DISTDIR}/${P}.json.gz" "spam-filter-rules-${PV}.json.gz"
}
