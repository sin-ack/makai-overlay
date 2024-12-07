# Copyright 2011-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

MY_PV="${PV/-r*/}"

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 linux-info unpacker xdg

DESCRIPTION="The Official Unity Hub"
HOMEPAGE="https://unity.com/unity-hub"
SRC_URI="https://hub.unity3d.com/linux/repos/deb/pool/main/u/unity/unityhub_amd64/unityhub-amd64-${MY_PV}.deb"

S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="appindicator +seccomp"
RESTRICT="bindist mirror strip test"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/nss
	sys-apps/util-linux
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-misc/xdg-utils
	appindicator? ( dev-libs/libayatana-appindicator )
"

QA_PREBUILT="*"

src_configure() {
	default
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	:
}

src_install() {
	dodir /
	cd "${ED}" || die
	unpacker

	# The desktop file has a TryExec line for "unityhub" but it's not actually
	# present on the path. Let's make it available as an executable.
	dosym ../../opt/unityhub/unityhub usr/bin/unityhub

	# The desktop file's Exec line refers to /opt/unityhub/unityhub but the
	# TryExec line refers to unityhub on the PATH. Let's unify those.
	sed -i '/^Exec/s#/opt/unityhub/##' "usr/share/applications/unityhub.desktop" \
		|| die "Failed to correct Exec path on desktop file"

	# Purge unused locales
	pushd opt/unityhub/locales >/dev/null || die "Failed to enter locales dir"
	chromium_remove_language_paks
	popd >/dev/null || die "Failed to exit locales dir"

	# Fix Debian-style documentation path
	pushd usr/share/doc >/dev/null || die "Failed to enter /usr/share/doc"
	mv unityhub "${PF}" || die "Failed to correct documentation path"
	popd >/dev/null || die "Failed to exit /usr/share/doc"

	# For some reason this binary is world-writable, fix that
	pushd opt/unityhub/UnityLicensingClient_V1 >/dev/null || die "Failed to enter licensing client dir"
	chmod go-w Unity.Licensing.Client || die "Failed to correct permissions on licensing client"
	popd >/dev/null || die "Failed to exit licensing client dir"

	# Ignore already-compressed files
	docompress -x "/usr/share/doc/${PF}/changelog.gz"

	# If seccomp is disabled, then disable the sandbox too.
	if ! use seccomp; then
		sed -i '/^Exec/s/unityhub/unityhub --disable-seccomp-filter-sandbox/' \
			"usr/share/applications/unityhub.desktop" ||
			die "sed failed for seccomp"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
}
