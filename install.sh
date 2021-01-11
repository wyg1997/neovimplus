#!/bin/bash
set -e

NEOVIM_CONFIG_DIR=~/.config/nvim
NEOVIM_DIR=~/.local/share/nvim/site

# 获取linux发行版名称
function get_linux_distro()
{
    if grep -Eq "Ubuntu" /etc/*-release; then
        echo "Ubuntu"
    elif grep -Eq "Deepin" /etc/*-release; then
        echo "Deepin"
    elif grep -Eq "LinuxMint" /etc/*-release; then
        echo "LinuxMint"
    elif grep -Eq "elementary" /etc/*-release; then
        echo "elementaryOS"
    elif grep -Eq "Debian" /etc/*-release; then
        echo "Debian"
    elif grep -Eq "Kali" /etc/*-release; then
        echo "Kali"
    elif grep -Eq "CentOS" /etc/*-release; then
        echo "CentOS"
    elif grep -Eq "fedora" /etc/*-release; then
        echo "fedora"
    elif grep -Eq "openSUSE" /etc/*-release; then
        echo "openSUSE"
    elif grep -Eq "Arch Linux" /etc/*-release; then
        echo "ArchLinux"
    elif grep -Eq "ManjaroLinux" /etc/*-release; then
        echo "ManjaroLinux"
    else
        echo "Unknow"
    fi
}

# 获取日期
function get_datetime()
{
    time=$(date "+%Y%m%d%H%M%S")
    echo $time
}

# 判断文件是否存在
function is_exist_file()
{
    filename=$1
    if [ -f $filename ]; then
        echo 1
    else
        echo 0
    fi
}

# 判断目录是否存在
function is_exist_dir()
{
    dir=$1
    if [ -d $dir ]; then
        echo 1
    else
        echo 0
    fi
}

# 获取ubuntu版本
function get_ubuntu_version()
{
    line=$(cat /etc/lsb-release | grep "DISTRIB_RELEASE")
    arr=(${line//=/ })
    version=(${arr[1]//./ })

    echo ${version[0]}
}

# 安装ubuntu必备软件
function install_prepare_software_on_ubuntu()
{
    echo "\n" | sudo add-apt-repository ppa:neovim-ppa/unstable

    version=$(get_ubuntu_version)
    if [ $version -eq 14 ];then
        sudo apt-get install -y cmake3
    else
        sudo apt-get install -y cmake
    fi

    sudo apt-get install -y neovim npm exuberant-ctags build-essential python python-dev python3-dev fontconfig libfile-next-perl ack-grep git
    # 安装最新版nodejs(coc.nvim要求)
    sudo npm config set registry https://registry.npm.taobao.org
    sudo npm install n -g
    sudo n stable
}

# 安装ubuntu系必备软件
function install_prepare_software_on_ubuntu_like()
{
    sudo apt-get update
    sudo apt-get install -y cmake exuberant-ctags build-essential python python-dev python3-dev fontconfig libfile-next-perl ack-grep git
}

# 安装archlinux必备软件
function install_prepare_software_on_archlinux()
{
    sudo pacman -S --noconfirm neovim ctags automake gcc cmake python3 ack git nodejs npm fontconfig
    sudo ln -s /usr/lib/libtinfo.so.6 /usr/lib/libtinfo.so.5
}

# 拷贝文件
function copy_files()
{
    mkdir -p ${NEOVIM_CONFIG_DIR}
    rm -rf ${NEOVIM_CONFIG_DIR}/init.vim
    ln -s ${PWD}/init.vim ${NEOVIM_CONFIG_DIR}

    rm -rf ${NEOVIM_CONFIG_DIR}/init.vim.custom.plugins
    ln -s ${PWD}/init.vim.custom.plugins ${NEOVIM_CONFIG_DIR}

    rm -rf ${NEOVIM_CONFIG_DIR}/init.vim.custom.config
    ln -s ${PWD}/init.vim.custom.config ${NEOVIM_CONFIG_DIR}

    mkdir -p ${NEOVIM_DIR}
    rm -rf ${NEOVIM_DIR}/colors
    ln -s ${PWD}/colors ${NEOVIM_DIR}

    rm -rf ${NEOVIM_DIR}/ftplugin
    ln -s ${PWD}/ftplugin ${NEOVIM_DIR}

    rm -rf ${NEOVIM_DIR}/autoload
    ln -s ${PWD}/autoload ${NEOVIM_DIR}
}

# 安装mac平台字体
function install_fonts_on_mac()
{
    rm -rf ~/Library/Fonts/Droid\ Sans\ Mono\ Nerd\ Font\ Complete.otf
    cp ./fonts/Droid\ Sans\ Mono\ Nerd\ Font\ Complete.otf ~/Library/Fonts
}

# 安装linux平台字体
function install_fonts_on_linux()
{
    mkdir -p ~/.local/share/fonts
    rm -rf ~/.local/share/fonts/Droid\ Sans\ Mono\ Nerd\ Font\ Complete.otf
    cp ./fonts/Droid\ Sans\ Mono\ Nerd\ Font\ Complete.otf ~/.local/share/fonts

    fc-cache -vf ~/.local/share/fonts
}

# TODO: some bugs here
# 安装coc.nvim补全支持
function install_coc_support()
{
    python3 -m pip install neovim jedi

    nvim -c "CocInstall coc-clangd" -c "q"  # -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    nvim -c "CocInstall coc-cmake" -c "q"
    nvim -c "CocInstall coc-git" -c "q"
    nvim -c "CocInstall coc-highlight" -c "q"
    nvim -c "CocInstall coc-jedi" -c "q"
    nvim -c "CocInstall coc-json" -c "q"
    nvim -c "CocInstall coc-python" -c "q"
    nvim -c "CocInstall coc-sh" -c "q"
    nvim -c "CocInstall coc-snippets" -c "q"
    nvim -c "CocInstall coc-vimlsp" -c "q"
    nvim -c "CocInstall coc-yaml" -c "q"
    nvim -c "CocInstall coc-syntax" -c "q"
    nvim -c "CocInstall coc-pairs" -c "q"
}

# 安装vim插件
function install_vim_plugin()
{
    rm -rf ~/.vim/plugged
    mkdir -p ~/.vim/plugged
    nvim -c "PlugInstall" -c "q" -c "q"

    install_coc_support
}

# 开始安装vimplus
function begin_install_vimplus()
{
    copy_files
    install_fonts_on_linux
    install_vim_plugin
}

# 在ubuntu上安装vimplus
function install_vimplus_on_ubuntu()
{
    install_prepare_software_on_ubuntu
    begin_install_vimplus
}

# 在ubuntu系上安装vimplus
function install_vimplus_on_ubuntu_like()
{
    backup_vimrc_and_vim
    install_prepare_software_on_ubuntu_like
    begin_install_vimplus
}

# 在archlinux上安装vimplus
function install_vimplus_on_archlinux()
{
    install_prepare_software_on_archlinux
    begin_install_vimplus
}

# 在linux平上台安装vimplus
function install_vimplus_on_linux()
{
    distro=`get_linux_distro`
    echo "Linux distro: "${distro}

    if [ ${distro} == "Ubuntu" ]; then
        install_vimplus_on_ubuntu
    elif [ ${distro} == "Deepin" ]; then
        # install_vimplus_on_ubuntu_like
        not_implement
    elif [ ${distro} == "LinuxMint" ]; then
        # install_vimplus_on_ubuntu_like
        not_implement
    elif [ ${distro} == "elementaryOS" ]; then
        # install_vimplus_on_ubuntu_like
        not_implement
    elif [ ${distro} == "Debian" ]; then
        # install_vimplus_on_debian
        not_implement
    elif [ ${distro} == "Kali" ]; then
        # install_vimplus_on_debian
        not_implement
    elif [ ${distro} == "CentOS" ]; then
        # install_vimplus_on_centos
        not_implement
    elif [ ${distro} == "fedora" ]; then
        # install_vimplus_on_fedora
        not_implement
    elif [ ${distro} == "openSUSE" ]; then
        # install_vimplus_on_opensuse
        not_implement
    elif [ ${distro} == "ArchLinux" ]; then
        install_vimplus_on_archlinux
    elif [ ${distro} == "ManjaroLinux" ]; then
        install_vimplus_on_archlinux
    else
        echo "Not support linux distro: "${distro}
    fi
}

# 获取当前时间戳
function get_now_timestamp()
{
    cur_sec_and_ns=`date '+%s-%N'`
    echo ${cur_sec_and_ns%-*}
}

function not_implement()
{
    echo "Not implement, please draft an issue in https://github.com/wyg1997/neovimplus/issues"
}

# main函数
function main()
{
    begin=`get_now_timestamp`

    type=$(uname)
    echo "Platform type: "${type}

    if [ ${type} == "Darwin" ]; then
        # install_vimplus_on_mac
        not_implement
    elif [ ${type} == "Linux" ]; then
        tp=$(uname -a)
        if [[ $tp =~ "Android" ]]; then
            echo "Android"
            # install_vimplus_on_android
            not_implement
        else
            install_vimplus_on_linux
        fi
    else
        echo "Not support platform type: "${type}
    fi

    end=`get_now_timestamp`
    second=`expr ${end} - ${begin}`
    min=`expr ${second} / 60`
    echo "It takes "${min}" minutes."
}

# 调用main函数
main
