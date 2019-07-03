#!/bin/sh

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Build GNU bash package installer

# 2019 Armin Briegel - Scripting OS X


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


# requires Xcode or Developer Command line tools

echo "## checking for Dev Tools"
if ! xcode-select -p ; then
    echo "this script requires Xcode or the Developer CLI tools to be installed"
    exit 1
fi


# setup the directories

projectdir=$(dirname "$0")
# replace '.' in the path
projectdir=$(python -c "import os; print(os.path.realpath('${projectdir}'))")

downloaddir="${projectdir}/downloads"
if [ ! -d "$downloaddir" ]; then
    mkdir -p "$downloaddir"
fi

builddir="${projectdir}/build"
if [ ! -d "$builddir" ]; then
    mkdir -p "$builddir"
fi


# setup paths and names

bashname="bash-${version}"
archivename="${bashname}.tar.gz"
archivepath="${downloaddir}/${archivename}"
ftpurl="ftp://ftp.gnu.org/gnu/bash"
archiveurl="${ftpurl}/${archivename}"


# clean out the build dir

# $builddir shouldn't be empty. But fail nevertheless, just to be safe
rm -Rf "${builddir:?}"/*


# download the archive

# check if archive already exists, don't re-download
if [ ! -f "${archivepath}" ]; then
    echo "## downloading $bashname to $archivepath"

    if ! curl "$archiveurl" -o "${archivepath}"; then
        echo "could not download ${archiveurl}"
        exit 1
    fi
fi


# extract the archive

echo "## extracting ${archivepath}"

if ! tar -xzf "${archivepath}" -C "${builddir}" ; then
    echo "could not extract ${archivename}"
    exit 1
fi

sourcedir="${builddir}/$bashname"
if [ ! -d "$sourcedir" ]; then
    echo "something went wrong, couldn't find $sourcedir"
    exit 1
fi

payloaddir="${builddir}/payload"
mkdir -p "$payloaddir"

patchesdir="${builddir}/patches"
mkdir -p "$patchesdir"

# download patches

echo "## downloading patches"

if ! cd "$patchesdir"; then 
    echo "something went wrong, cannot change directory to $patchesdir"
    exit 1
fi

nodotversion=$(printf '%s' "$version" | tr -d '.') # removes '.'

patcheslist=$(curl "${ftpurl}/${bashname}-patches/" -l --silent )

for patchname in $patcheslist; do
    # skip files with sig extension
    if [ "${patchname##*.}" != "sig" ]; then
        #echo "downloading $patchname"
        curl "${ftpurl}/${bashname}-patches/${patchname}" --silent -O
    fi
done

#curl "https://ftp.gnu.org/gnu/bash/bash-${version}-patches/bash${nodotversion}-[001-099]" -f --silent -O

# apply patches

echo "## applying patches"

if ! cd "$sourcedir" ; then
    echo "something went wrong, cannot change directory to $sourcedir"
    exit 1
fi

patchcount=0
for p in "$patchesdir/bash${nodotversion}-"???; do
    if patch -p0 -i "$p" --quiet; then
        patchcount=$((patchcount +1))
    else
        echo "## error while patching $p"
        exit 1
    fi
done

echo "## applied $patchcount patches"

if [ $patchcount -gt 0 ]; then
    patchedversion="$version.$patchcount"
else
    patchedversion="$version"
fi

# configure

echo "## configuring $sourcedir"

"$sourcedir/configure" --prefix="$payloaddir" --quiet


# build

echo "## building in $payloaddir"

make install --quiet


# rename the bash binary to bash4 or bash5

if [ $renamebinary -eq 1 ]; then
    # get first part of version
    majorversion="${version%%.*}"
    
    echo "## renaming binary to bash${majorversion}"
    
    mv "${payloaddir}/bin/bash" "${payloaddir}/bin/bash${majorversion}"
fi


# build the pkg

pkgpath="${projectdir}/${pkgname}-${patchedversion}.pkg"

echo "## building package $pkgpath"

pkgbuild --root "${payloaddir}" \
         --identifier "${identifier}" \
         --version "${patchedversion}" \
         --scripts "${projectdir}/scripts" \
         --install-location "${install_location}" \
         "${pkgpath}"
         
# reveal pkg in Finder
if [ -e "$pkgpath" ]; then
    open -R "$pkgpath"
fi


