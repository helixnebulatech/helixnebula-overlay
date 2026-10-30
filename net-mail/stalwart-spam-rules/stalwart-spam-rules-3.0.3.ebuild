# Copyright 2026 helixnebulatech
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Spam filter rules for the Stalwart mail server"
HOMEPAGE="https://github.com/stalwartlabs/spam-filter"
# Manifest hash = the one from the GitHub API (sha256
# 43124c2ecfb9c5f187c1b9415ae7d37be1318ce0be91132750962a77c5f62505, checked 2026-10-30).
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
