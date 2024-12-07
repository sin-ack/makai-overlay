# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="i3/sway-like layout for hyprland"
HOMEPAGE="https://github.com/outfoxxed/hy3"
SRC_URI="https://github.com/outfoxxed/hy3/archive/refs/tags/hl${PV}.tar.gz"

S="${WORKDIR}/hy3-hl${PV}"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64"

# hy3 releases are directly tied to the matching Hyprland release, up to the minor
# version.
RDEPEND="
	>=gui-wm/hyprland-$(ver_cut 1-2 "${PV}").0
	<gui-wm/hyprland-$(ver_cut 1).$(("$(ver_cut 2 "${PV}")" + 1))
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

pkg_postinst() {
	elog "To use hy3, you will need to configure it as described here:"
	elog "    https://github.com/outfoxxed/hy3/blob/hl${PV}/README.md#configuration"
	elog "Add this line as the first configuration line of your hyprland.conf file:"
	elog "    plugin = ${EPREFIX}/usr/$(get_libdir)/libhy3.so"
}
