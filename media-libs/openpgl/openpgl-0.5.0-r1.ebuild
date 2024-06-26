# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION="Intel Open Path Guiding Library"
HOMEPAGE="https://github.com/OpenPathGuidingLibrary/openpgl"
SRC_URI="https://github.com/OpenPathGuidingLibrary/openpgl/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="-* ~amd64 ~arm64"

X86_CPU_FLAGS=( sse4_2 avx2 avx512dq )
CPU_FLAGS=( cpu_flags_arm_neon "${X86_CPU_FLAGS[@]/#/cpu_flags_x86_}" )
IUSE="${CPU_FLAGS[*]} debug"

RDEPEND="
	media-libs/embree:=
	dev-cpp/tbb:=
"
DEPEND="${RDEPEND}"

pkg_pretend() {
	if use amd64 ; then
		if ! use cpu_flags_x86_sse4_2 && ! use cpu_flags_x86_avx2 && ! use cpu_flags_x86_avx512dq ; then
			die "You need to select a compatible ISA"
		fi
	elif use arm64 ; then
		if ! use cpu_flags_arm_neon; then
			die "You need to select a compatible ISA"
		fi
	fi
}

src_configure() {
	local mycmakeargs=(
		-DOPENPGL_ISA_SSE4="$(usex cpu_flags_x86_sse4_2)"
		-DOPENPGL_ISA_AVX2="$(usex cpu_flags_x86_avx2)"
		-DOPENPGL_ISA_AVX512="$(usex cpu_flags_x86_avx512dq)"
		-DOPENPGL_ISA_NEON="$(usex cpu_flags_arm_neon)"
		# TODO look into neon 2x support
		# -DOPENPGL_ISA_NEON2X="$(usex cpu_flags_arm_neon2x)"
	)

	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	use cpu_flags_arm_neon && append-flags -flax-vector-conversions

	# Disable asserts
	append-cppflags "$(usex debug '' '-DNDEBUG')"

	cmake_src_configure
}
