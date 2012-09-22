#!/usr/bin/env sh

endpath="$HOME/.kload-awesome"

warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

echo "backing up current kload config\n"
today=`date +%Y%m%d`
for i in $HOME/.config/awesome $endpath; do [ -e $i ] && mv $i $i.$today; done

echo "cloning kload-awesome\n"
git clone --recursive http://github.com/Kloadut/awesome-debian.git $endpath

sed -i s/\#HOME\#/$(echo $HOME | sed 's/\//\\\//g')/g $endpath/rc.lua
sed -i s/\#HOME\#/$(echo $HOME | sed 's/\//\\\//g')/g $endpath/themes/skymod/theme.lua

ln -s $endpath $HOME/.config/awesome

echo "copying Robot font\n"
cp $endpath/fonts/* $HOME/.fonts/

echo "clearing font cache\n"
fc-cache -vf

echo "Done\n"
