# Copyright 2026 helixnebulatech
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Hardened memory allocator from GrapheneOS"
HOMEPAGE="https://github.com/GrapheneOS/hardened_malloc"
# Upstream signs its tags with an SSH key (contact@grapheneos.org,
# SHA256:AhgHif0mei+9aNyKLfMZBh2yptHdw/aN7Tlh/j2eFwM). The GitHub tarball of this tag was
# checked to be identical to the signed tree; the Manifest pins its hash.
SRC_URI="https://github.com/GrapheneOS/hardened_malloc/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cxx llvm-libunwind"
# Upstream's tests need python and are meant for the default glibc setup.
RESTRICT="test"

# USE=cxx (upstream's CONFIG_CXX_ALLOCATOR, enabled by default as in GrapheneOS) replaces C++
# new/delete and checks the size passed to sized delete. The library then links the C++
# runtime, so every program that loads it (linked or via LD_PRELOAD) needs that runtime too,
# even plain C programs. The runtime is chosen with llvm-libunwind, which LLVM profiles force:
# there it is libc++ (whose libc++abi does not declare libunwind); elsewhere it is libstdc++,
# shipped with gcc. A plain || ( ) would pick gcc for an empty ROOT on LLVM profiles.
RDEPEND="
	cxx? (
		llvm-libunwind? (
			llvm-runtimes/libcxx
			llvm-runtimes/libcxxabi
			llvm-runtimes/libunwind
		)
		!llvm-libunwind? ( sys-devel/gcc:*[cxx] )
	)
"

# Built variants:
#  default -> libhardened_malloc.so        (all protections)
#  light   -> libhardened_malloc-light.so  (no quarantines, no write-after-free check,
#             no slot randomization; for workloads where the cost is too high)
VARIANTS=( default light )

hm_make() {
	# CONFIG_NATIVE=false: respect -march from CFLAGS instead of forcing -march=native.
	# CONFIG_WERROR=false: a new compiler warning must not break the build.
	# CFLAGS/CXXFLAGS/LDFLAGS come from the environment: passed as make arguments they
	# would replace the Makefile's own hardening flags instead of being prepended to them.
	# CXX = CC, as upstream does with CONFIG_CXX_ALLOCATOR (keeps LTO consistent).
	emake \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCC)" \
		CONFIG_NATIVE=false \
		CONFIG_WERROR=false \
		CONFIG_CXX_ALLOCATOR=$(usex cxx true false) \
		"$@"
}

src_compile() {
	local v suffix
	for v in "${VARIANTS[@]}"; do
		[[ ${v} == default ]] && suffix= || suffix=-${v}
		# Upstream sets no SONAME; give each library its own file name as SONAME.
		LDFLAGS="${LDFLAGS} -Wl,-soname,libhardened_malloc${suffix}.so" \
			hm_make VARIANT="${v}"
	done
}

src_install() {
	dolib.so out/libhardened_malloc.so
	dolib.so out-light/libhardened_malloc-light.so
	doheader include/h_malloc.h
	dodoc README.md
}

pkg_postinst() {
	elog "hardened_malloc is not used automatically. Two ways to use it:"
	elog " - Link it into programs at build time (recommended: also covers setuid programs,"
	elog "   where the loader ignores LD_PRELOAD, and services). In make.conf, then rebuild:"
	elog "     LDFLAGS=\"\${LDFLAGS} -Wl,--push-state,--no-as-needed,-lhardened_malloc,--pop-state\""
	elog "   Exclude sys-libs/hardened_malloc itself and your libc via package.env."
	elog " - Preload it for a single program:"
	elog "     LD_PRELOAD=${EPREFIX}/usr/$(get_libdir)/libhardened_malloc.so program"
	elog "It needs many memory mappings: set vm.max_map_count to at least 1048576"
	elog "(see 'Traditional Linux-based operating systems' in the upstream README)."
}
