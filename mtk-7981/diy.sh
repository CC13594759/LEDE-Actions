# 修改默认IP
sed -i 's/192.168.1.1/192.168.12.1/g' package/base-files/files/bin/config_generate

# 移除要替换的包
rm -rf feeds/packages/net/xray-core
rm -rf feeds/packages/net/v2ray-geodata

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# airconnect
git clone --depth=1 https://github.com/CC13594759/luci-app-airconnect package/luci-app-airconnect

# 科学上网插件
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2

# 修改本地时间格式
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version}/g" package/lean/default-settings/files/zzz-default-settings
sed -i 's/distversion)%>/distversion)%><!--/g' package/lean/autocore/files/*/index.htm
sed -i 's/luciversion)%>)/luciversion)%>)-->/g' package/lean/autocore/files/*/index.htm

# 修复 armv8 设备 xfsprogs 报错
sed -i 's/TARGET_CFLAGS.*/TARGET_CFLAGS += -DHAVE_MAP_SYNC -D_LARGEFILE64_SOURCE/g' feeds/packages/utils/xfsprogs/Makefile

# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 修改插件名字
sed -i 's/"PassWall 2"/"PassWall"/g' `egrep "PassWall 2" -rl ./`

#修改插件位置
sed -i "/exit 0/i\sed -i 's/nas/services/g' /usr/lib/lua/luci/controller/samba4.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "/exit 0/i\sed -i 's/nas/services/g' /usr/lib/lua/luci/controller/aria2.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "/exit 0/i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/aria2/overview_status.htm" package/lean/default-settings/files/zzz-default-settings

#替换luci源
sed -i 's|^#src-git luci https://github.com/coolsnowwolf/luci|src-git luci https://github.com/coolsnowwolf/luci|' feeds.conf.default
sed -i 's|^src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05|#src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05|' feeds.conf.default

# etc默认设置
#cp -a $GITHUB_WORKSPACE/mtk-7981/etc/* package/base-files/files/etc/

./scripts/feeds update -a
./scripts/feeds install -a
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua
sed -i 's/VPN/Services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm
./scripts/feeds update -a
./scripts/feeds install -a