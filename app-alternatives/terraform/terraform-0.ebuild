# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ALTERNATIVES=(
	"tofu:>=app-admin/opentofu-1.6.1-r1"
	"hashicorp-terraform:>=app-admin/terraform-1.7.2-r1"
)

inherit app-alternatives

DESCRIPTION="Terraform symlink"
KEYWORDS="~amd64 ~arm64 ~riscv"

RDEPEND="
	!<app-admin/terraform-1.7.2-r1
	!<app-admin/opentofu-1.6.1-r1
"

src_install() {
	dosym "$(get_alternative)" /usr/bin/terraform || die
}
