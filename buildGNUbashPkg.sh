#!/bin/bash

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# you can pass the version to download as argument 1
# only tested with some versions of bash4 and bash5
# use at your own risk with older versions
# change the default when newer versions of bash5 are published
version="${1:-5.0}"

# set this to `1` to change the `bash` binary name to `bash4` or `bash5`
# set this to `0` to keep the name as `bash`
renamebinary=1

# more variables

pkgname="GNU-bash"
identifier="org.gnu.bash"
install_location="/usr/local"


# requires Xcode or Developer Command line tools to be installs

if ! xcode-select -p ; then
    echo "this script requires Xcode or the Developer CLI tools to be installed"
    exit 1
fi


# setup the directories

projectdir=$(dirname "$0")
# replace '.' in the path
projectdir=$(python -c "import os; print(os.path.realpath('${projectdir}'))")

downloaddir="${projectdir}/downloads"
if [[ ! -d "$downloaddir" ]]; then
    mkdir -p "$downloaddir"
fi

builddir="${projectdir}/build"
if [[ ! -d "$builddir" ]]; then
    mkdir -p "$builddir"
fi


# clean out the build dir

rm -Rf "${builddir:?}"/*


# setup paths and names

bashname="bash-${version}"
archivename="${bashname}.tar.gz"
archivepath="${downloaddir}/${archivename}"
url="ftp://ftp.gnu.org/gnu/bash/${archivename}"


# download the archive

if [[ ! -f "${archivepath}" ]]; then
    echo "downloading $bashname"

    if ! curl "$url" -o "${archivepath}"; then
        echo "could not download ${url}"
        exit 1
    fi
fi


# extract the archive

echo "extracting ${archivepath}"


if ! tar -xzvf "${archivepath}" -C "${builddir}" ; then
    echo "could not extract ${archivename}"
    exit 1
fi

sourcedir="${builddir}/$bashname"
if [[ ! -d "$sourcedir" ]]; then
    echo "something went wrong, couldn't find $sourcedir"
    exit 1
fi

payloaddir="${builddir}/payload"
mkdir -p "$payloaddir"


# configure

echo "configuring $sourcedir"

if ! cd "$sourcedir" ; then
    echo "something went wrong, cannot cd to $sourcedir"
    exit 1
fi

"$sourcedir/configure" --srcdir="$sourcedir" --prefix="$payloaddir"


# build

echo "building in $payloaddir"

make install


# rename the bash binary to bash4 or bash5

if [[ $renamebinary -eq 1 ]]; then
    majorversion="${version:0:1}"
    echo "renaming binary to bash${majorversion}"
    mv "${payloaddir}/bin/bash" "${payloaddir}/bin/bash${majorversion}"
fi


# build the pkg

pkgpath="${projectdir}/${pkgname}-${version}.pkg"

pkgbuild --root "${payloaddir}" \
         --identifier "${identifier}" \
         --version "${version}" \
         --scripts "${projectdir}/scripts" \
         --install-location "${install_location}" \
         "${pkgpath}"
