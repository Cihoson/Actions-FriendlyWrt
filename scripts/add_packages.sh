#!/bin/bash

# {{ Add luci-app-diskman
(cd friendlywrt && {
    mkdir -p package/luci-app-diskman
    wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile.old -O package/luci-app-diskman/Makefile
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
CONFIG_PACKAGE_smartmontools=y
EOL
# }}

# {{ Add luci-theme-argon
(cd friendlywrt/package && {
    [ -d luci-theme-argon ] && rm -rf luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function old_init_theme/g' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
cat > /tmp/appendtext.txt <<EOL
function init_theme() {
    if uci get luci.themes.Argon >/dev/null 2>&1; then
        uci set luci.main.mediaurlbase="/luci-static/argon"
        uci commit luci
    fi
}
EOL
sed -i -e '/boardname=/r /tmp/appendtext.txt' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
# }}

# {{ Add TurboACC (mufeng05 版) - 完整保留所有功能 + 彻底解决 nftables/libnftnl 冲突
(cd friendlywrt && {
    curl -sSL https://raw.githubusercontent.com/mufeng05/turboacc/main/add_turboacc.sh -o /tmp/add_turboacc.sh
    bash /tmp/add_turboacc.sh
})

# === 彻底删除所有冲突的 fullcone 补丁（nftables + libnftnl）===
rm -f friendlywrt/package/network/utils/nftables/patches/*fullcone* || true
rm -f friendlywrt/package/network/utils/nftables/patches/999-01-nftables-add-fullcone-expression-support.patch || true
rm -f friendlywrt/package/libs/libnftnl/patches/*fullcone* || true
rm -f friendlywrt/package/libs/libnftnl/patches/999-01-libnftnl-add-fullcone-expression-support.patch || true

# === 完整保留 TurboACC 所有功能（Fullcone + Shortcut-FE + BBR）===
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-turboacc=y
CONFIG_TURBOACC_INCLUDE_FULLCONE=y
CONFIG_TURBOACC_INCLUDE_SHORTCUT_FE=y
CONFIG_TURBOACC_INCLUDE_BBR=y
CONFIG_PACKAGE_nft-fullcone=y
EOL
# }}
