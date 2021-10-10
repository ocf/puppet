#!/bin/zsh
export LANG=C

# quick-fedora-hardlink uses the the fullfiletimelist files present in the
# Fedora repository, as well as some specific properties of the structure of
# the Fedora repository, to "quickly" hardlink identical files in that
# repository.

# In the Fedora repository, all files which are hardlinked also have exactly
# the same names.  We also know that all files should have the same
# permissions, and so we don't need to check them.
#
# The specific property it uses is the fact that all hardlinked files will have
# the same name.

# "quickly" is defined as "faster than hardlink".  Even though this is just a
# shell script and will fork a whole lot, it only has to compare a handful of
# files compare to hardlink which has to look at every file in the repository.

# Generally, quick-fedora-mirror will maintain hardlinks as they are present on
# the master mirror.  However, there are situations where it won't:
# * If a module is added without backdating.
# * If files need to be retransferred for any reason.
# * If the file lists on the master aren't generated for each crosslinked
#   module together when linking occurs.

#
# Hardlinking
# From the file lists, we can collect all files which have identical names and/or sizes.
#
# we know that all of the hardkinked files also have the same names, we can
# limit that set further.
# Then, extract the dirnames from each of those, sort -u, and pass them all to hardlink.

# Default arguments; override in quick-fedora-mirror.conf
VERBOSE=0

FILELIST='fullfiletimelist-$mdir'

db1 () { (( VERBOSE >= 1 )) && echo $* }
db2 () { (( VERBOSE >= 2 )) && echo $* }
db3 () { (( VERBOSE >= 3 )) && echo '>>' $* }
db4 () { (( VERBOSE >= 4 )) && echo '>>>>' $* }
sep () { (( VERBOSE >= 2 )) && echo '============================================================' }
db2f () { (( VERBOSE >= 2 )) && printf $* }

hardlink () {
    echo "Move $2 out of the way"
    echo "ln $1 $2"
    echo "Target $1  New Link $2"

}

# Parse args
while [[ $# > 0 ]]; do
    opt=$1
    case $opt in
        -c)
            cfgfile=$2
            shift
            if [[ ! -r $cfgfile ]]; then
                (>&2 echo Cannot read $cfgfile)
                exit 1
            fi
            ;;
        -d) # Debugging
            verboseopt=$2
            shift
            ;;
        -n)
            skiplink=1
            ;;
        -p) # Progress
            progress=1
            ;;
        *)
            (>&2 echo "Unrecognized argument.")
            exit 1
            ;;
    esac
    shift
done

# Load up the configuration file
for file in $cfgfile /etc/quick-fedora-mirror.conf \
        ~/.config/quick-fedora-mirror.conf \
        $(dirname $0)/quick-fedora-mirror.conf \
        ./quick-fedora-mirror.conf; do
    if [[ -r $file ]]; then
        source $file
        db3 "Loaded config $file"
        break
    fi
done

# Override with the command-line option
[[ -n $verboseopt ]] && VERBOSE=$verboseopt

# Make a tempdir and trap.
tempd=$(mktemp -d -t quick-hardlink.XXXXXXXXXX)
tuples=$tempd/alltuples
if (( VERBOSE <= 8 )); then
    trap "rm -rf $tempd" EXIT
fi

cd $DESTD
filelists=()
totallines=0
for mdir in *; do
    if [[ ! -d $mdir ]]; then
        continue
    fi
    # Look for a file list in there
    flname=$mdir/${FILELIST/'$mdir'/$mdir}

    if [[ -f $flname ]]; then
        tmpname=$tempd/files-$mdir
        db2 "Exracting file list from $flname."
        linecount=$(wc -l < $flname)

        awk -v PROG=$progress -v MDIR=$mdir -v TL=$linecount -F'\t' '
            /^\[Files/ {
                s = 1
                next
            }
            /^$/ {
                s = 0
                next
            }
            s && $2 == "f" {
                printf("%s/%s\t%s\n", MDIR, $4, $3)
            }
            PROG == 1 && NR % 100000 == 0 {
                printf("  Processed %10d lines, %3.2f%% done\n", NR, 100*NR/TL) > "/dev/stderr"
            }
        ' $flname > $tmpname

    # filter the list, if necessary
    if [[ -n $FILTEREXP ]]; then
        sed -i -r -e "\,$FILTEREXP,d" $tmpname
    fi

        filelists+=($tmpname)
        linecount=$(wc -l < $tmpname)
        totallines=$((totallines + linecount))
        db2f "%7d total files in %s.\n" $linecount $flname
    fi
done

# ZSHISM? array member coount
echo "Lists to process: $#filelists"
echo "Total lines: $totallines"

awk -v TL=$totallines -v PROG=$progress -F'\t' '
    $1 ~ /\// {
        bn = (basename($1) $2)
        if (allfiles[bn]) {
            multiples[bn]=1
            allfiles[bn] = (allfiles[bn] "\t" $1)
        }
        else {
            allfiles[bn] = $1
        }
    }
    PROG== 1 && FNR == 0 {
        printf("Processing %s\n", FILENAME) > "/dev/stderr"
    }
    PROG == 1 && NR % 100000 == 0 {
        printf("  Processed %10d lines, %3.2f%% done\n", NR, 100*NR/TL) > "/dev/stderr"
    }

    END {
        for (key in multiples) {
            print allfiles[key]
        }
    }

    function basename(pn) {
        if (sub(".*/", "", pn)) {
            return pn
        }
    }
' $filelists >> $tuples

sort $tuples > $tuples-sorted

# Now we have this big file with all tuples
sep
linecount=$(wc -l < $tuples-sorted)
db2 "Found $linecount potential hardlinkable tuples."

tuple=()
count=0
# ZSHISM read into array.  Bash uses readarray?
while IFS=$'\t' read -A tuple; do
    count=$((count+1))
    if (( count % 10000 == 0 )); then
        pct=$(( 100 * count / linecount ))
        printf "========= %8d processed (%2.2) =========\n" $count $pct
    fi
    target=$tuple[1]
    targetinode=$(stat -c %i $target)

    # ZSHISM does bash even have array slicing?
    for candidate in ${tuple[2,-1]}; do

        # First check inodes to weed out already linked files
        candidateinode=$(stat -c %i $candidate)
        if (( targetinode == candidateinode )); then
            db3 "$target and $candidate are already hardlinked."
            continue
        fi

        # Then actually check the file contents
        cmp -s $target $candidate
        if [[ $? != 0 ]]; then
            db2 "$target and $candidate share the same name but have different contents."
            continue
        fi

        db2 "$target and $candidate are the same and can be hardlinked."

        if [[ $skiplink == 1 ]]; then
            continue
        fi

        # And now we can hardlink.
        candidatedir=$(dirname $candidate)
        tempfile=$(mktemp -p $candidatedir quick-hardlink.XXXXXXXXXX)
        if [[ $? != 0 ]]; then
            (>&2 echo "Could not create temporary file in $candidatedir.")
            exit 1
        fi

        # Move the candidate out of the way.
        mv $candidate $tempfile
        if [[ $? != 0 ]]; then
            (>&2 echo "Could not rename $candidate.")
            exit 1
        fi

        # Make the link
        ln $target $candidate
        if [[ $? != 0 ]]; then
            (>&2 echo "Could not link from $candidate to $target. Trying to undo the rename.")
            mv $tempfile $candidate
            if [[ $? != 0 ]]; then
                (>&2 echo "Could not rename $tmpfile to $candidate!  You will
                need to fix things up manually.")
            else
                (>&2 echo "Undid the rename.")
            fi
        fi

        # Delete the tempfile.
        rm -f $tempfile
        if [[ $? != 0 ]]; then
            (>&2 echo "Could not delete the tempfile $tempfile.  You will need to clean this up manually.  Continuing.")
        fi
    done
done < $tuples-sorted
