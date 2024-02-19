# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGO_PN="github.com/NVIDIA/${PN}"

inherit go-module

DESCRIPTION="NVIDIA container runtime toolkit"
HOMEPAGE="https://github.com/NVIDIA/nvidia-container-toolkit"

if [[ "${PV}" == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/NVIDIA/${PN}.git"
	inherit git-r3

	src_unpack() {
		git-r3_src_unpack
	}
else
	SRC_URI="https://github.com/NVIDIA/${PN}/archive/v${PV/_rc/-rc.}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${PV/_rc/-rc.}"
	KEYWORDS="~amd64"
	RESTRICT="mirror"
fi

LICENSE="Apache-2.0"
SLOT="0"

IUSE=""

RDEPEND="
	sys-libs/libnvidia-container
"

DEPEND="${RDEPEND}"

BDEPEND="
	app-arch/unzip
	dev-build/make
"

src_unpack() {
	default
	go-module_src_unpack

	# When -buildmode=pie is enabled on nvidia-container-toolkit
	# versions prior to 1.15.0, the following error is observed:
	# "error while loading shared libraries: unexpected PLT reloc type 0x00"
	GOFLAGS="${GOFLAGS//-buildmode=pie/}"
}


src_compile() {
	emake binaries
}

src_install() {
	# Fixed by https://github.com/vizv
	dobin "nvidia-container-runtime"
	dobin "nvidia-container-runtime-hook"
	dobin "nvidia-ctk"
	insinto "/etc/nvidia-container-runtime"
	doins "${FILESDIR}/config.toml"
}

pkg_postinst() {
	elog "Your docker service must restart after install this package."
	elog "OpenRC: sudo rc-service docker restart"
	elog "systemd: sudo systemctl restart docker"
	elog "You may need to edit your /etc/nvidia-container-runtime/config.toml"
	elog "file before running ${PN} for the first time."
	elog "For details, please see the NVIDIA docker manual page."
}
