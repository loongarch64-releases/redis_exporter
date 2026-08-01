#!/bin/bash
set -euo pipefail

UPSTREAM_OWNER=oliver006
UPSTREAM_REPO=redis_exporter
VERSION="${1}"
echo "   🏢 Org:   ${UPSTREAM_OWNER}"
echo "   📦 Proj:  ${UPSTREAM_REPO}"
echo "   🏷️  Ver:   ${VERSION}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DISTS="${ROOT_DIR}/dists"
SRCS="${ROOT_DIR}/srcs"

mkdir -p "${DISTS}/${VERSION}" "${SRCS}"

# ==========================================
# 👇 用户自定义构建逻辑 (示例)
# ==========================================

# ======================================================================

PATCHES="${ROOT_DIR}/patches"
BUILD_DIR="${SRCS}/${VERSION}"
DIST_DIR="${DISTS}/${VERSION}"

echo "🔧 Compiling ${UPSTREAM_OWNER}/${UPSTREAM_REPO} ${VERSION}..."

# 1. 准备阶段：安装依赖、下载代码、应用补丁等
prepare()
{
    echo "📦 [Prepare] Setting up build environment..."
    
    # TODO: 在此处添加准备命令
    rm -rf ${SRCS}/${VERSION}
    git clone -b ${VERSION} --depth=1 https://github.com/oliver006/redis_exporter ${SRCS}/${VERSION}
    (
        cd ${SRCS}/${VERSION}
        for patch_ in ${PATCHES}/*.patch; do
            patch -p1 < ${patch_}
        done
    )
    
    echo "✅ [Prepare] Environment ready."
}

# 2. 编译阶段：核心构建命令
build()
{
    echo "🔨 [Build] Compiling source code..."
    
    # TODO: 在此处添加编译命令
    (
        cd ${SRCS}/${VERSION}
        GITHUB_REF_NAME=${VERSION} make build-some-loong64-binaries
        ./package-github-binaries.sh
    )

    echo "✅ [Build] Compilation finished."
}

# 3. 后处理阶段：整理产物、清理临时文件、验证版本
post_build()
{
    echo "📦 [Post-Build] Organizing artifacts..."
    
    # TODO: 在此处添加整理命令
    # 例如：mkdir -p dists && cp binary dist/
    # 例如：strip dist/binary
    
    cp ${BUILD_DIR}/dist/* $DIST_DIR/

    echo "✅ [Post-Build] Artifacts ready in ./dists/${VERSION}."
}

# 主入口
main()
{
    prepare
    build
    post_build
}

main

# ==========================================
# 👆 自定义逻辑结束
# ==========================================

cat > "${DISTS}/${VERSION}/release.txt" <<EOF
Project: ${UPSTREAM_REPO}
Organization: ${UPSTREAM_OWNER}
Version: ${VERSION}
Build Time: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

echo "✅ Compilation finished."
ls -lh "${DISTS}/${VERSION}"
