# Shared functions and setup
umask 002

FIXED_CONTENT=abcdefghijklmnopqrstuvwxyz
FIXED_CSUM=$(echo -n $FIXED_CONTENT | sha1sum | awk '{print $1}')

create_some_files () {
    # Create a few files and fil them with some data.
    #  Some files will contain random data; file0 will always contain a-z with
    #  no newline and should alwys be 26 bytes in size.
    local dir=$1
    local count=3
    local i

    if [[ -n $2 ]]; then
        count=$2
    fi

    mkdir -p $dir
    echo -n $FIXED_CONTENT > file0
    for i in $dir/file{1..$count}; do
        echo $i > $i
        date +%s%N >> $i
    done
}

create_dir_structure () {
    local dir=$1
    local count=3
    local nest=2
    local i

    if [[ -n $2 ]]; then
        count=$2
    fi

    if [[ -n $3 ]]; then
        nest=$3
    fi

    mkdir -p $dir
    pushd $dir
    create_some_files .

    if (( nest > 1 )); then
        nest=$(( nest -1 ))
        for i in dir{1..$count}; do
            create_dir_structure $i $count $nest
            #mkdir $i
            #create_some_files $i $count
        done
    fi
    popd
}

dirs_similar () {
    # Do two directories have the same contents?
    #
    # run recursive diff
    local d1=$1
    local d2=$2

    diff -r $d1 $d2 >> $so 2>$se
}

dirs_contents_identical () {
    # Are the files in two directories completely identical, including file
    # time and permissions?
    #
    # run find . -type f -printf '%T@\t%m\t%p\n' for each directory and diff the result.
    # Might have problems with the fractional part of mtime.
    local d1=$1
    local d2=$2

    local c1=$od/contents1
    local c2=$od/contents2

    # Note that rsync <= 3.0.9 won't copy subsecond timestamps
    local rsyncver=$(rsync --version | head -1 | awk '{print $3}')
    local -a splitver; splitver=(${(s/./)rsyncver})

    if (( splitver[1] >= 3 && splitver[2] >= 1 )); then
        find $d1 -type f -printf '%T@\t%m\t%P\n' |sort -k3 > $c1
        find $d2 -type f -printf '%T@\t%m\t%P\n' |sort -k3 > $c2
    else
        find $d1 -type f -printf '%Ts\t%m\t%P\n' |sort -k3 > $c1
        find $d2 -type f -printf '%Ts\t%m\t%P\n' |sort -k3 > $c2
    fi

    diff -u $c1 $c2 > $so 2>$se

    # Cat those files for verbose tests
}

dirs_identical () {
    # Are two trees completely identical, including directory timestamps?
    local d1=$1
    local d2=$2

    local c1=$od/contents1
    local c2=$od/contents2

    # Note that rsync <= 3.0.9 won't copy subsecond timestamps
    local rsyncver=$(rsync --version | head -1 | awk '{print $3}')
    local -a splitver; splitver=(${(s/./)rsyncver})

    if (( splitver[1] >= 3 && splitver[2] >= 1 )); then
        find $d1 -printf '%T@\t%m\t%P\n' |sort -k3 > $c1
        find $d2 -printf '%T@\t%m\t%P\n' |sort -k3 > $c2
    else
        find $d1 -printf '%Ts\t%m\t%P\n' |sort -k3 > $c1
        find $d2 -printf '%Ts\t%m\t%P\n' |sort -k3 > $c2
    fi

    diff -u $c1 $c2 > $so 2>$se
}

files_contents_identical () {
    local f1=$1
    local f2=$2

    if [[ ! -e $f1 || ! -e $f2 ]]; then
        return 1
    fi

    local s1=$(sha1sum $f1 | awk '{print $1}')
    local s2=$(sha1sum $f2 | awk '{print $1}')

    if [[ $s1 != $s2 ]]; then
        echo "Checksums:" >> $so
        echo $s1 >> $so
        echo $s2 >> $so
        return 1
    fi

    return 0
}

files_hardlinked () {
    # Are two files hardlinked?
    local f1=$1
    local f2=$2

    if [[ ! -e $f1 || ! -e $f2 ]]; then
        return 1
    fi

    i1=$(stat -c %i $f1)
    i2=$(stat -c %i $f2)

    if [[ $i1 -ne $i2 ]]; then
        echo "Inodes:"
        echo $i1 >> $so
        echo $i1 >> $so
        return 1
    fi

    return 0
}

file_contains () {
    local f=$1
    # Turn TAB into literal tabs
    local p=${2//TAB/	}
    shift

    grep -P -- "$p" $f
}

# Sleep until the next second tick
sleep_next_second () {
    sleep 1
}

oneTimeSetUp () {
    # For this test suite we'll be doing the same setup for everything
    sd=$SHUNIT_TMPDIR/scratch
    od=$SHUNIT_TMPDIR/output
    mkdir $od

    so=$od/stdout
    se=$od/stderr

    tdup=$SHUNIT_TMPDIR/top
    td=$tdup/sub

    mdir=$SHUNIT_TMPDIR/mirror
    srcdir=$mdir/src
    destdir=$mdir/dest
    master=$srcdir/master
    tl=$td/fullfiletimelist
    fl=$td/fullfilelist
}

find-shunit () {
    local i

    for i in \
        $SHUNIT \
        shunit2 \
        ../shunit2 \
        ../../shunit2 \
        /usr/share/shunit2/shunit2 \
        ; do
        if [[ -r $i ]]; then
            echo $i
            return
        fi
    done
    (>&2 echo "Cannot locate shunit2; exiting")
    exit 1
}
