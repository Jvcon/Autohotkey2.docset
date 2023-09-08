#!/bin/bash

# ======= Function ========
build_en() {
    jq '.externalURL = "https://www.autohotkey.com/docs/v2/" ' $BASE_DIR/dashing.json >$SRC_ZH_DIR/v2/docs/dashing.json
    # cp -r $BASE_DIR/dashing.json $SRC_EN_DIR/docs/dashing.json
    cp -r $BASE_DIR/icons.png $SRC_EN_DIR/docs/icons.png
    cp -r $BASE_DIR/content.js $SRC_EN_DIR/docs/static/content.js
    cd $SRC_EN_DIR/docs/
    rm -rf AutoHotkey2.docset
    dashing build
    rm ./AutoHotkey2.docset/Contents/Resources/Documents/icons.png
    case "$mode" in
    build)
        echo "Building a compress"
        tar -czf AutoHotkey2-en_us.tgz AutoHotkey2.docset
        mv AutoHotkey2-en_us.tgz $Output_DIR
        ;;
    test)
        if [ -d "$TAR_EN_DIR" ]; then
            echo "The '$TAR_EN_DIR' folder exists. Deleting..."
            # Delete the folder
            rm -r "$TAR_EN_DIR"
        fi
        echo "Moving docset folder to test"
        mv -f AutoHotkey2.docset $TAR_EN_DIR
        ;;
    all | "") ;;

    *)
        echo "Invalid"
        exit 1
        ;;
    esac
    echo "Cleaning..."
    git clean -fd
}

build_zh() {
    jq '.externalURL = "https://wyagd001.github.io/v2/docs/" ' $BASE_DIR/dashing.json >$SRC_ZH_DIR/v2/docs/dashing.json
    # cp -r $BASE_DIR/dashing.json $SRC_ZH_DIR/v2/docs/dashing.json
    cp -r $BASE_DIR/icons.png $SRC_ZH_DIR/v2/docs/icons.png
    cp -r $BASE_DIR/content.js $SRC_ZH_DIR/v2/docs/static/content.js
    cd $SRC_ZH_DIR/v2/docs/
    rm -rf AutoHotkey2.docset
    dashing build
    rm ./AutoHotkey2.docset/Contents/Resources/Documents/icons.png
    python3 $BASE_DIR/beautifulsoup.py $SRC_ZH_DIR/v2/docs/AutoHotkey2.docset
    case "$mode" in
    build)
        echo "Building a compress"
        tar -czf AutoHotkey2-zh_cn.tgz AutoHotkey2.docset
        mv AutoHotkey2-zh_cn.tgz $Output_DIR
        ;;
    test)
        if [ -d "$TAR_ZH_DIR" ]; then
            echo "The '$TAR_ZH_DIR' folder exists. Deleting..."
            # Delete the folder
            rm -r "$TAR_ZH_DIR"
        fi
        echo "Moving docset folder to test"
        mv -f AutoHotkey2.docset $TAR_ZH_DIR
        ;;
    all | "") ;;

    *)
        echo "Invalid"
        exit 1
        ;;
    esac
    echo "Cleaning..."
    git clean -fd
}

# ======= Main ======
# Load environment variables
if [ -f .env ]; then
    export $(cat .env | sed 's/#.*//g' | xargs)
fi

mode=$1
lang=$2

BASE_DIR=$(
    cd $(dirname $0)
    pwd
)
Output_DIR=$BASE_DIR/output

SRC_EN_DIR=$BASE_DIR/doc2en
SRC_ZH_DIR=$BASE_DIR/doc2zh
TAR_EN_DIR=$DOCSET_DIR/AutoHotkey2EN.docset
TAR_ZH_DIR=$DOCSET_DIR/AutoHotkey2ZH.docset

rm -rf $Output_DIR
mkdir $Output_DIR

# Initial
if ! [ -x "$(command -v python3)" ] &&
    ! [ -x "/usr/local/bin/python3" ] &&
    ! [ -x "/usr/bin/python3" ]; then
    echo "Python is not installed"
    sudo apt install -y python3 python3-pip
else
    if [[ $(python3 --version) != Python\ 3.* ]]; then
        echo "Required Python version not installed"
        sudo apt install -y python3 python3-pip
    fi
fi

if ! [ -x "$(command -v go)" ]; then
    echo "Go is not installed"
    sudo apt install -y golang
fi

if ! [ -x "$(command -v git)" ]; then
    echo "Git is not installed"
    sudo apt install -y git
fi

if ! [ -x "$(command -v jq)" ]; then
    echo "jq is not installed"
    sudo apt install -y jq
fi

git version
python3 --version
go version

pip install -r requirements.txt
go install github.com/technosophos/dashing@latest

# Check & update submodule
submodules=(
    "doc2en"
    "doc2zh"
)

for i in "${submodules[@]}"; do
    git submodule update --remote ./$i
done

case "$lang" in
zh) build_zh ;;
en) build_en ;;
all | "")
    build_zh
    build_en
    ;;
*)
    echo "Invalid"
    exit 1
    ;;
esac
