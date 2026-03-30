#!/bin/bash

sed -i -e '/CONFIG_MAKE_TOOLCHAIN=y/d' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_IB=y/# CONFIG_IB is not set/g' configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_SDK=y/# CONFIG_SDK is not set/g' configs/rockchip/01-nanopi
# ==================== 禁用不需要的服务 ====================
cat >> configs/rockchip/01-nanopi << 'EOL'

# 禁用 DDNS（LuCI 界面）
# CONFIG_PACKAGE_luci-app-ddns is not set

# 禁用 Samba（文件共享）
# CONFIG_PACKAGE_luci-app-samba4 is not set
# CONFIG_PACKAGE_samba4-server is not set

# 禁用 Aria2（下载工具 + LuCI 界面）
# CONFIG_PACKAGE_luci-app-aria2 is not set
# CONFIG_PACKAGE_aria2 is not set

# 禁用 Watchcat
# CONFIG_PACKAGE_luci-app-watchcat is not set

EOL
