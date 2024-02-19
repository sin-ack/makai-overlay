# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker udev

DESCRIPTION="Codemeter License Server"
HOMEPAGE="https://www.wibu.com/us/products/codemeter.html"
SRC_URI="codemeter_${PV}_amd64.deb"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
# The Codemeter license server requires the .deb file to be downloaded from their website.
RESTRICT="fetch"
IUSE="doc man systemd"

# Extracted from the .deb. Some dependencies don't match exactly so I omitted them.
RDEPEND="
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libglvnd
	sys-process/procps
	sys-libs/glibc
	sys-libs/zlib
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	virtual/libusb:1
"

QA_PREBUILT="*"
QA_DESKTOP_FILE="usr/share/applications/codemeter.desktop"
S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please go to https://www.wibu.com/support/user/user-software.html and"
	einfo "download \"CodeMeter User Runtime for Linux\" (version 8.00, 2023-12-05,"
	einfo "multilanguage), and then place it in ${EROOT}/var/cache/distfiles."
	einfo
	einfo "The expected filename is ${SRC_URI}."
}

src_unpack() {
	:
}

src_install() {
	dodir /
	cd "${ED}" || die
	unpacker

	# Move library paths from Debian to Gentoo conventions
	insinto /usr/"$(get_libdir)"
	doins -r usr/lib/x86_64-linux-gnu/*
	rm -rf usr/lib/x86_64-linux-gnu

	# Keep empty dirs in the .deb
	keepdir /var/lib/CodeMeter/Backup
	keepdir /var/lib/CodeMeter/CmAct
	keepdir /var/lib/CodeMeter/CmCloud
	keepdir /var/lib/CodeMeter/NamedUser
	keepdir /var/lib/CodeMeter/WebAdmin
	keepdir /var/log/CodeMeter

	if use doc; then
		# Fixup doc paths to match Gentoo policy
		docdir="/usr/share/doc/${PF}"
		insinto "$docdir"
		doins -r usr/share/doc/codemeter/*
		doins -r usr/share/doc/CodeMeter/*
	fi

	# Remove non-compliant directories
	rm -rf usr/share/doc/CodeMeter usr/share/doc/codemeter

	# Ignore already-compressed files
	use man && docompress -x usr/share/man/man1/codemeter-info.1.gz
	use doc && docompress -x usr/share/doc/${PF}/changelog.gz
	use doc && docompress -x usr/share/doc/${PF}/CmUserHelp/us/OpenSource_en.txt.gz

	# Delete Debian-specific initscripts
	rm -rf etc/init.d

	if ! use systemd; then
		# Copy our own initscripts
		exeinto /etc/init.d
		newexe "${FILESDIR}/codemeter-initd" codemeter
		newexe "${FILESDIR}/codemeter-webadmin-initd" codemeter-webadmin
	fi

	# Remove files not included with USE flags
	use systemd || rm -rf lib/systemd
	use man || rm -rf usr/share/man
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
