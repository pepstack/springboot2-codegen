#!/bin/bash
#
# @file
#
# @author: zhangliang@ztgame
#
# @create: 2014-12-18
#
# @update: 2018-06-12 14:15:35
#
########################################################################
# Error Codes:
#
ERR_NOERROR=0

ERR_FATAL_ERROR=-100

# current user is not a root
ERR_NOT_ROOT=100

# file is already existed
ERR_FILE_EXISTED=200

#-----------------------------------------------------------------------
# detect_color_support
#   - Try to detect color support.
#-----------------------------------------------------------------------
_COLORS=${BS_COLORS:-$(tput colors 2>/dev/null || echo 0)}
function detect_color_support() {
    if [ $? -eq 0 ] && [ "$_COLORS" -gt 2 ]; then
        RC="\033[1;31m"
        GC="\033[1;32m"
        BC="\033[1;34m"
        YC="\033[1;33m"
        EC="\033[0m"
    else
        RC=""
        GC=""
        BC=""
        YC=""
        EC=""
    fi
}
detect_color_support


#-----------------------------------------------------------------------
# echoerror
#   - Echo errors to stderr.
#-----------------------------------------------------------------------
function echoerror() {
    printf "${RC} * ERROR${EC}: %s\n" "$@" 1>&2;
}

#-----------------------------------------------------------------------
# echoinfo
#   - Echo information to stdout.
#-----------------------------------------------------------------------
function echoinfo() {
    printf "${GC} *  INFO${EC}: %s\n" "$@";
}

#-----------------------------------------------------------------------
# echowarn
#   - Echo warning informations to stdout.
#-----------------------------------------------------------------------
function echowarn() {
    printf "${YC} *  WARN${EC}: %s\n" "$@";
}

#-----------------------------------------------------------------------
# echodebug
#   - Echo debug information to stdout.
#-----------------------------------------------------------------------
function echodebug() {
    if [ "$_ECHO_DEBUG" -eq $BS_TRUE ]; then
        printf "${BC} * DEBUG${EC}: %s\n" "$@";
    fi
}


function error_exit {
  echoerror "$1" 1>&2
  exit 1
}


#***********************************************************
# chk_root
#   check if is a root user
#
# Example:
#   chk_root
#***********************************************************
function chk_root() {
    if [ $UID -ne 0 ]; then
        echoerror "check root failed: current user is not a root !!" \
            "Because you will run all the steps from this shell with root privileges," \
            "You must become root right by typing:" \
            "  $ sudo su"
        exit $ERR_NOT_ROOT
    fi
}


#***********************************************************
# read_cfg
#   read section and key from ini file
#
# Example:
#   value=$(read_cfg $CFG_FILE $SEC_NAME 'key')
#***********************************************************
function read_cfg() {
    CFGFILE=$1
    SECTION=$2
    KEYNAME=$3

    RETVAL=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEYNAME'/{print $2;exit}' $CFGFILE`
    echo $RETVAL | tr -d '"'
}


#***********************************************************
# write_cfg
#   write section and key to ini file
#
# Example:
#   $(write_cfg $CFG_FILE 'secname' 'key' $value)
#***********************************************************
function write_cfg() {
    CFGFILE=$1
    SECTION=$2
    KEYNAME=$3
    NEWVAL=$4

    RETVAL=`sed -i "/^\[$SECTION\]/,/^\[/ {/^\[$SECTION\]/b;/^\[/b;s/^$KEYNAME*=.*/$KEYNAME=$NEWVAL/g;}" $CFGFILE`
    echo $RETVAL
}


#***********************************************************
# real_path
#   get real path of given relative path
#
# Example:
#   ABS_PATH=$(real_path $(dirname $0))
#***********************************************************
function real_path() {
    \cd "$1"
    /bin/pwd
}


#***********************************************************
# copy_file
#   copy source file to destigation file without overwriting
#
# Example:
#   copy_file $file1 $file2
#***********************************************************
function copy_file() {
    src=$1
    dst=$2

    if [ -a $dst ]
    then
        echoerror "<copy_file> file is already existed: '$dst'"
        exit $ERR_FILE_EXISTED
    fi

    echoinfo "<copy_file> '$src' => '$dst'"

    dstdir=$(dirname $dst)

    if [ -d $dstdir ]
    then
        :
    else
        mkdir -p $dstdir
    fi

    cp -p $src $dst
}


#***********************************************************
# is_empty_dir
#    if a dir is empty
# Returns:
#    0 - not empty dir
#    1 - is empty dir
#    2 - dir not existed
# Example:
#    is_empty_dir ~/workspace
#    echo $?
#
#    $(is_empty_dir './'
#    echo $?
#***********************************************************
DIR_NOT_EXISTED=2
DIR_IS_EMPTY=1
DIR_NOT_EMPTY=0

function is_empty_dir() {
    local olddir=$PWD
    local indir=$1

    if [ ! -d "$indir" ]; then
        return $DIR_NOT_EXISTED
    fi

    cd $indir
    local files=`ls 2>/dev/null`
    cd $olddir

    if [ -n "$files" ]; then
        return $DIR_NOT_EMPTY
    else
        return $DIR_IS_EMPTY
    fi
}


function mktemp_file() {
    TMPDIR=`mktemp -d /tmp/$1.XXXX`
    TMPFILE=`mktemp $TMPDIR/$2.XXXX`
    echo $TMPFILE
}


function now_datetime() {
    dt=$(date +%Y-%m-%d)
    tm=$(date +%H:%M:%S)
    echo "$dt $tm"
}


function ipaddr2number() {
    local ipaddr=$1
    local a=`echo $ipaddr|awk -F . '{print $1}'`
    local b=`echo $ipaddr|awk -F . '{print $2}'`
    local c=`echo $ipaddr|awk -F . '{print $3}'`
    local d=`echo $ipaddr|awk -F . '{print $4}'`
    echo "$(((d<<24)+(c<<16)+(b<<8)+a))"
}


function number2ipaddr() {
    local num=$1
    local a=$((num>>24))
    local b=$((num>>16&0xff))
    local c=$((num>>8&0xff))
    local d=$((num&0xff))
    echo "$d.$c.$b.$a"
}


function os_alias_version() {
    id=`lsb_release -i -s`
    ver=`lsb_release -r -s`
    lc=$(echo $id$ver | tr '[A-Z]' '[a-z]')
    echo "$lc"
}


function validate_ipv4() {
    echo $1|grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" > /dev/null;

    if [ $? -ne 0 ]; then
        # bad ipv4 address
        return 1
    fi

    local ipaddr=$1
    local a=`echo $ipaddr|awk -F . '{print $1}'`
    local b=`echo $ipaddr|awk -F . '{print $2}'`
    local c=`echo $ipaddr|awk -F . '{print $3}'`
    local d=`echo $ipaddr|awk -F . '{print $4}'`
    local n

    for n in $a $b $c $d
    do
        if [ $n -gt 255 ] || [ $n -lt 0 ]; then
            # bad ipv4 address
            return 1
        fi
    done

    # good ipv4 address
    return 0
}


# 字符串分割成数组
#   strsplit "I,am,a,boy" ","
#
function strsplit() {
    OLD_IFS="$IFS"
    IFS="$2"
    local arr=($1)
    IFS="$OLD_IFS"

    echo ${arr[*]}
}


function strarray_at() {
    local array=$1
    local at=$2

    local i=0
    local col=""
    local s

    for s in ${array[@]}
    do
        if [ "$i" -eq "$at" ]; then
            col="$s"
            break
        fi
        ((i++))
    done

    echo $col
}


# 得到指定进程名的进程 pid 数组
#   pids_of_proc "$procname"
#
function pids_of_proc() {
    local procname="$1"

    local c_pid=`ps -ef | grep $procname | grep -v ' grep ' | awk '{print $2}'`

    if [ -z "$c_pid" ]; then
        echo ""
    else
        local pids

        OLD_IFS="$IFS"
        IFS="\n"
        pids=($c_pid)
        IFS="$OLD_IFS"

        echo "$c_pid"
    fi
}


# 得到进程打开的文件描述符数目
# get number of opened file descriptors for given process id (pid)
#    openfd_of_pid "$pid"
#
function openfd_of_pid() {
    local c_pid="$1"

    local ret=`lsof -p $c_pid -n|awk '{print $2}'|sort|uniq -c|sort -nr|more`

    if [ -z "$ret" ]; then
        echo 0
    else
        local arr=$(strsplit "$ret" " ")
        local numofd=$(strarray_at "$arr" 0)
        echo "$numofd"
    fi
}
