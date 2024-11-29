#!/bin/sh

set -ue

# (c) Copyright Fabrice Le Fessant INRIA/OCamlPro 2013
# (c) Copyright Louis Gesbert OCamlPro 2014-2017

VERSION='2.1.2'
DEV_VERSION='2.1.2'
DEFAULT_BINDIR=/usr/local/bin

bin_sha512() {
  case "$OPAM_BIN" in
    ### opam 2.0 series ###

    opam-2.0.10-arm64-linux)     echo "cef611335dd406bad9bc70b10345938d054a19824dcef474471216d1ba08454a827927ad014d49485fb4e7fd808cfaa041ef90081505a42838809c090b089966";;
    opam-2.0.10-arm64-macos)     echo "6cffe9457d6b1b0df1255776f93bef242316a03ff4c3ac3802f45921abf9d17a1396361ad947591351f7c4f7e5072dab758c952ab7822ede76c24b7dc1a12803";;
    opam-2.0.10-armhf-linux)     echo "61cac30543becfe217018cd999160b4e77435c43a8c8a9203d713ed3bb2cf14ba02901688a14a377186709d5fb4c24b0fc9ba2027a4c9ce1ceff7c0a955568a2";;
    opam-2.0.10-i686-linux)      echo "31b8a3e6afe6c5ca5ff5d921b4ed8ed3255131c184e9af19f5268c743d49a0789f9a5b780261d988b836b11eadf801f279d3538cb46dc66d753b6d12232e98b8";;
    opam-2.0.10-x86_64-linux)    echo "f644038fd8ebcebba1bbdf3550a2dee05c8b8da92b78e83fc085c9b8f3c78c654170c83971c651e86a16731271ecdf8903fb9fdd9b6dcd65679ce97c111ca631";;
    opam-2.0.10-x86_64-macos)    echo "0f6a8e38200bc7592fb49819d1c4c4d8834fa5185de16a3409d563b6308a484dd60590ecc96992b36d59ef908f5843a98b607161e124de700bb01dd4f2a88c39";;
    opam-2.0.10-x86_64-openbsd)  echo "fd8cb4a387283eebd9db58ab5c090e674f0885117a34622ef9db7f9380003d2b84341cf9adaab7367eecb5773f96770d21db1d4cd4a0849b22427830ab4a1475";;

    ### opam 2.1 series ###


    opam-2.1.0-arm64-linux)     echo "216185106deb81db0e9cb329dd7f01d097173e1e7a055a1af8525cdb4dde6d443e4bf4ef8377f1cbd4c9fecdc7ea03e6f294dad30b10a0e83959476018e24972";;
    opam-2.1.0-arm64-macos)     echo "c8a46b2d554e4b2a68d5004ad4cee24425c75a6957c40af49d21e05875925e59d29ef3c9f0d7703f9c209b3f50107959fa853b32143f9e7deb7b4cc54006d668";;
    opam-2.1.0-armhf-linux)     echo "ed6448d5b4f4f8aa8d7f1d84aa09b851c9760a0ece0177ee9efecd6e6d778cd3d3c7bc6c5fb1be316d99288fdb3740dcdd88ed890b85218eb84e8b776137584f";;
    opam-2.1.0-i686-linux)      echo "f401ae0b65ae86169d1125b6068bfd9ad897339b69882ef2a3d1e67df909e93f5f41967679d31d2336b3b8dd854806b5b97d8ab7b9fb05f7b21291ca506e6f33";;
    opam-2.1.0-x86_64-linux)    echo "03c6a85f13a452749fdb2271731f3624a3993498ff2b304123231a8f2b26ccf1182d12119466e9a85f4de370fca51bd61d0eefe6280d3ca087cf4620fdc59a22";;
    opam-2.1.0-x86_64-macos)    echo "1c9acee545c851dd3701229e3a6aa7b5650620e37e01400d797a4b1fbeeb614adc459411283684e223a72fda8b14ba6c6e5482661485f888819f6a2a02e4d279";;
    opam-2.1.0-x86_64-openbsd)  echo "d53bab13e38f9e1304e08ad437b5486263451d754c9ba5feb638a34d2d2acaeef412eeae4bc9fb6bc7ee9c07539a88e02029162dbfbb095248255bc7d772213d";;

    opam-2.1.1-arm64-linux)     echo "503875dff416bc76966d58be6e9236662fc7c598d705a913ba3a3cf9861008ce598dddf2df17dbb13c2fc2e64346e54f001483ab512b50a11a36da178c67b7d6";;
    opam-2.1.1-arm64-macos)     echo "eea30844d867f36e8359ed8987e0b094e4077c845aa3e1c962dc5e476831eb97ff809aa1533c6d28ae8c36d0febf20eedef69e161a86971a46bffa6ea8d41790";;
    opam-2.1.1-armhf-linux)     echo "8bdecf77a19e173f2ffc0cee2f668411ab680a3e8669095e9d95c1d36cf03d269b89b1f314c96f00590d46c5b89f6763a960803ed0b88456b8dd707e8bcdbb78";;
    opam-2.1.1-i686-linux)      echo "94feacfc35184a27b9e6ee6a04cb71d5764b4daa36504eaed34130033e0fb80828c1a750422df943d54c8911b1f83e67e67e77d8214751f689fc3445c4a71f84";;
    opam-2.1.1-x86_64-linux)    echo "494d32320d09eb2cb4d94e06d0133db1cbfccdf7a673eacffca4f190684497d9f4273680222cb197d88353f67661219675df58753b393dd5faf32400bf8ce044";;
    opam-2.1.1-x86_64-macos)    echo "3b88eeaf523b4820b7909f4f38dce33b9ca77c27b5008cc2d1100176ee54c0f2df5b6c427973fbcc850bda942ea8c3d4b113c3bc05c3a8ddaf4a2d46f8eec65f";;
    opam-2.1.1-x86_64-openbsd)  echo "09d7f392754a12b812d698ef3dab646f53e1f1f5cd591e1fdffb017a948798e5ba8758207ffdc3be7a5fab97df711ca896bf4b2897ca85af2f88ff0f7ae78e28";;

    opam-2.1.2-arm64-linux)     echo "439b4d67c2888058df81b265148a3468b753c14700a8be38d091b76bf2777b5da5e9c8752839a92878cd377dd4bfbd5c3a458e7a26bff73e35056b60591d30f0";;
    opam-2.1.2-arm64-macos)     echo "55879f3e18bbc70c32d06f21f4ef785d54ef052920f57f1847c2cddc15af2f08e82d32022e7284fa43b07d56e4ba2f5155956b3673c3def8cd2f5c2cb8f68e48";;
    opam-2.1.2-armhf-linux)     echo "b9ee73e04ebaab23348e990b6e1d678fa0a66f5c0124e397761c6b9b2f1a8cb6fb2fa97da119aed52077777777777777777777891c72b088be8088c9547362d7";;
    opam-2.1.2-i686-linux)      echo "85a480d60e09a7d37fa0d0434ed97a3187434772ceb4e7e8faa5b06bc18423d004af3ad5849c7d35e72dca155103257fd6b1178872df8291583929eb8f884b6a";;
    opam-2.1.2-x86_64-freebsd)  echo "50abe8d91bc2fde43565f40d12ff18a1eceaad51483db3d7c6619bce70920d0a3845fad8993b8bfad24c9d550c4b6a5c12d55fb8a5f26c0da25f221b68307f4b";;
    opam-2.1.2-x86_64-linux)    echo "c0657ecbd4dc212587a4da70c5ff0402df95d148867be0e1eb1be8863a285107777777777777777777753fcaa56cac99169c76ec94c5787750d7a59cd1fbb68b";;
    opam-2.1.2-x86_64-macos)    echo "5ec63f3e4e4e93decb7580d0a114d3ab5eab49baea29edd80c8b4c86b7ab5224e654035903538ef4b63090ab3c2967d6efcc46bf0e8abf239ecc3e04ad7304e2";;
    opam-2.1.2-x86_64-openbsd)  echo "7c16d67777777777777777777777777777777777777777777777777777777777ac242eb7f7aa94b21ad1b579bd857143b6f1ef98b0a53bd3c7047f13fcf95219";;

    *) echo "no sha";;
  esac
}

usage() {
    echo "opam binary installer v.$VERSION"
    echo "Downloads and installs a pre-compiled binary of opam $VERSION to the system."
    echo "This can also be used to switch between opam versions"
    echo
    echo "Options:"
    echo "    --dev                  Install the latest alpha or beta instead: $DEV_VERSION"
    echo "    --no-backup            Don't attempt to backup the current opam root"
    echo "    --backup               Force the backup the current opam root (even if it"
    echo "                           is from the 2.0 branch already)"
    echo "    --fresh                Create the opam $VERSION root from scratch"
    echo "    --restore   VERSION    Restore a backed up opam binary and root"
    echo "    --version   VERSION    Install this specific version instead of $VERSION"
    echo
    echo "The default is to backup if the current version of opam is 1.*, or when"
    echo "using '--fresh' or '--dev'"
}

RESTORE=
NOBACKUP=
FRESH=
DOWNLOAD_ONLY=

while [ $# -gt 0 ]; do
    case "$1" in
        --dev)
            if [ $VERSION = $DEV_VERSION ]; then
              echo "There is no dev version. Launching with last release $VERSION."
            fi
            VERSION=$DEV_VERSION
            if [ -z "$NOBACKUP" ] && [ $VERSION != $DEV_VERSION ]; then NOBACKUP=0; fi;;
        --restore)
            if [ $# -lt 2 ]; then echo "Option $1 requires an argument"; exit 2; fi
            shift;
            RESTORE=$1;;
        --version)
            if [ $# -lt 2 ]; then echo "Option $1 requires an argument"; exit 2; fi
            shift;
            VERSION=$1;;
        --no-backup)
            NOBACKUP=1;;
        --backup)
            NOBACKUP=0;;
        --fresh)
            FRESH=1;;
        --download-only)
            DOWNLOAD_ONLY=1;;
        --help|-h)
            usage; exit 0;;
        *)
            usage; exit 2;;
    esac
    shift
done


TMP=${TMPDIR:-/tmp}

ARCH=$(uname -m || echo unknown)
case "$ARCH" in
    x86|i?86) ARCH="i686";;
    x86_64|amd64) ARCH="x86_64";;
    ppc|powerpc|ppcle) ARCH="ppc";;
    aarch64_be|aarch64) ARCH="arm64";;
    armv5*|armv6*|earmv6*|armv7*|earmv7*|armv8b|armv8l) ARCH="armhf";;
    *) ARCH=$(echo "$ARCH" | awk '{print tolower($0)}')
esac

OS=$( (uname -s || echo unknown) | awk '{print tolower($0)}')

if [ "$OS" = "darwin" ] ; then
  OS=macos
fi

TAG=$(echo "$VERSION" | tr '~' '-')

OPAM_BIN_URL_BASE='https://github.com/ocaml/opam/releases/download/'
OPAM_BIN="opam-${TAG}-${ARCH}-${OS}"
OPAM_BIN_URL="${OPAM_BIN_URL_BASE}${TAG}/${OPAM_BIN}"

download() {
    if command -v wget >/dev/null; then wget -q -O "$@"
    else curl -s -L -o "$@"
    fi
}

check_sha512() {
    OPAM_BIN_LOC="$1"
    if command -v openssl > /dev/null; then
        sha512_devnull="cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"
        sha512_check=`openssl sha512 2>&1 < /dev/null | cut -f 2 -d ' '`
        if [ "x$sha512_devnull" = "x$sha512_check" ]; then
            sha512=`openssl sha512 "$OPAM_BIN_LOC" 2> /dev/null | cut -f 2 -d ' '`
            check=`bin_sha512`
            test "x$sha512" = "x$check"
        else
            echo "openssl 512 option not handled, binary integrity check can't be performed."
            return 0
        fi
    else
        echo "openssl not found, binary integrity check can't be performed."
        return 0
    fi
}

download_and_check() {
    OPAM_BIN_LOC="$1"
    echo "## Downloading opam $VERSION for $OS on $ARCH..."

    if ! download "$OPAM_BIN_LOC" "$OPAM_BIN_URL"; then
        echo "There may not yet be a binary release for your architecture or OS, sorry."
        echo "See https://github.com/ocaml/opam/releases/tag/$TAG for pre-compiled binaries,"
        echo "or run 'make cold' from https://github.com/ocaml/opam/archive/$TAG.tar.gz"
        echo "to build from scratch"
        exit 10
    else
        if check_sha512 "$OPAM_BIN_LOC"; then
            echo "## Downloaded."
        else
            echo "Checksum mismatch, a problem occurred during download."
            exit 10
        fi
    fi
}

DOWNLOAD_ONLY=${DOWNLOAD_ONLY:-0}

if [ $DOWNLOAD_ONLY -eq 1 ]; then
    OPAM_BIN_LOC="$PWD/$OPAM_BIN"
    if [ -e "$OPAM_BIN_LOC" ]; then
        echo "Found opam binary in $OPAM_BIN_LOC ..."
        if check_sha512 "$OPAM_BIN_LOC" ; then
            echo "... with matching sha512"
            exit 0;
        else
            echo "... with mismatching sha512, download the good one."
        fi
    fi
    download_and_check "$OPAM_BIN_LOC"
    exit 0;
fi

EXISTING_OPAM=$(command -v opam || echo)
EXISTING_OPAMV=
if [ -n "$EXISTING_OPAM" ]; then
   EXISTING_OPAMV=$("$EXISTING_OPAM" --version || echo "unknown")
fi

FRESH=${FRESH:-0}

OPAMROOT=${OPAMROOT:-$HOME/.opam}

if [ ! -d "$OPAMROOT" ]; then FRESH=1; fi

if [ -z "$NOBACKUP" ] && [ ! "$FRESH" = 1 ] && [ -z "$RESTORE" ]; then
    case "$EXISTING_OPAMV" in
        2.*) NOBACKUP=1;;
        *) NOBACKUP=0;;
    esac
fi

xsudo() {
    local CMD=$1; shift
    local DST
    for DST in "$@"; do : ; done

    local DSTDIR=$(dirname "$DST")
    if [ ! -w "$DSTDIR" ]; then
        echo "Write access to $DSTDIR required, using 'sudo'."
        echo "Command: $CMD $@"
        if [ "$CMD" = "install" ]; then
            sudo "$CMD" -g 0 -o root "$@"
        else
            sudo "$CMD" "$@"
        fi
    else
        "$CMD" "$@"
    fi
}

if [ -n "$RESTORE" ]; then
    OPAM=$(command -v opam)
    OPAMV=$("$OPAM" --version)
    OPAM_BAK="$OPAM.$RESTORE"
    OPAMROOT_BAK="$OPAMROOT.$RESTORE"
    if [ ! -e "$OPAM_BAK" ] || [ ! -d "$OPAMROOT_BAK" ]; then
        echo "No backup of opam $RESTORE was found"
        exit 1
    fi
    if [ "$NOBACKUP" = 1 ]; then
        printf "## This will clear $OPAM and $OPAMROOT. Continue ? [Y/n] "
        read R
        case "$R" in
            ""|"y"|"Y"|"yes")
                xsudo rm -f "$OPAM"
                rm -rf "$OPAMROOT";;
            *) exit 1
        esac
    else
        xsudo mv "$OPAM" "$OPAM.$OPAMV"
        mv "$OPAMROOT" "$OPAMROOT.$OPAMV"
    fi
    xsudo mv "$OPAM_BAK" "$OPAM"
    mv "$OPAMROOT_BAK" "$OPAMROOT"
    printf "## Opam $RESTORE and its root were restored."
    if [ "$NOBACKUP" = 1 ]; then echo
    else echo " Opam $OPAMV was backed up."
    fi
    exit 0
fi

if [ -e "$TMP/$OPAM_BIN" ] && ! check_sha512 "$TMP/$OPAM_BIN" || [ ! -e "$TMP/$OPAM_BIN" ]; then
    download_and_check "$TMP/$OPAM_BIN"
else
    echo "## Using already downloaded \"$TMP/$OPAM_BIN\""
fi

if [ -n "$EXISTING_OPAM" ]; then
    DEFAULT_BINDIR=$(dirname "$EXISTING_OPAM")
fi

while true; do
    printf "## Where should it be installed ? [$DEFAULT_BINDIR] "
    read BINDIR
    if [ -z "$BINDIR" ]; then BINDIR="$DEFAULT_BINDIR"; fi

    if [ -d "$BINDIR" ]; then break
    else
        printf "## $BINDIR does not exist. Create ? [Y/n] "
        read R
        case "$R" in
            ""|"y"|"Y"|"yes")
            xsudo mkdir -p $BINDIR
            break;;
        esac
    fi
done

if [ -e "$EXISTING_OPAM" ]; then
    if [ "$NOBACKUP" = 1 ]; then
        xsudo rm -f "$EXISTING_OPAM"
    else
        xsudo mv "$EXISTING_OPAM" "$EXISTING_OPAM.$EXISTING_OPAMV"
        echo "## $EXISTING_OPAM backed up as $(basename $EXISTING_OPAM).$EXISTING_OPAMV"
    fi
fi

if [ -d "$OPAMROOT" ]; then
    if [ "$FRESH" = 1 ]; then
        if [ "$NOBACKUP" = 1 ]; then
            printf "## This will clear $OPAMROOT. Continue ? [Y/n] "
            read R
            case "$R" in
                ""|"y"|"Y"|"yes")
                    rm -rf "$OPAMROOT";;
                *) exit 1
            esac
        else
            mv "$OPAMROOT" "$OPAMROOT.$EXISTING_OPAMV"
            echo "## $OPAMROOT backed up as $(basename $OPAMROOT).$EXISTING_OPAMV"
        fi
        echo "## opam $VERSION installed. Please run 'opam init' to get started"
    elif [ ! "$NOBACKUP" = 1 ]; then
        echo "## Backing up $OPAMROOT to $(basename $OPAMROOT).$EXISTING_OPAMV (this may take a while)"
        if [ -e "$OPAMROOT.$EXISTING_OPAMV" ]; then
            echo "ERROR: there is already a backup at $OPAMROOT.$EXISTING_OPAMV"
            echo "Please move it away or run with --no-backup"
        fi
        FREE=$(df -k "$OPAMROOT" | awk 'NR>1 {print $4}')
        NEEDED=$(du -sk "$OPAMROOT" | awk '{print $1}')
        if ! [ $NEEDED -lt $FREE ]; then
            echo "Error: not enough free space to backup. You can retry with --no-backup,"
            echo "--fresh, or remove '$OPAMROOT'"
            exit 1
        fi
        cp -a "$OPAMROOT" "$OPAMROOT.$EXISTING_OPAMV"
        echo "## $OPAMROOT backed up as $(basename $OPAMROOT).$EXISTING_OPAMV"
    fi
    rm -f "$OPAMROOT"/repo/*/*.tar.gz*
fi

xsudo install -m 755 "$TMP/$OPAM_BIN" "$BINDIR/opam"
echo "## opam $VERSION installed to $BINDIR"

if [ ! "$FRESH" = 1 ]; then
    echo "## Converting the opam root format & updating"
    "$BINDIR/opam" init --reinit -ni
fi

WHICH=$(command -v opam || echo notfound)

case "$WHICH" in
    "$BINDIR/opam") ;;
    notfound) echo "## Remember to add $BINDIR to your PATH";;
    *)
        echo "## WARNING: 'opam' command found in PATH does not match the installed one:"
        echo "   - Installed: '$BINDIR/opam'"
        echo "   - Found:     '$WHICH'"
        echo "Make sure to remove the second or fix your PATH to use the new opam"
        echo
esac

if [ ! "$NOBACKUP" = 1 ]; then
    echo "## Run this script again with '--restore $EXISTING_OPAMV' to revert."
fi

rm -f $TMP/$OPAM_BIN
