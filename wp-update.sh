#!/bin/bash -e
#
# Backup and update WordPress using wp-cli
#

# Set PATH environment variable
export PATH="/usr/local/bin:/usr/bin:/bin"

# Check if wp-cli is installed.
if [ ! $(which wp) > /dev/null ] ; then
    echo -e "$0 requires wp-cli.\nFor more info visit wp-cli.org or github.com/wp-cli/wp-cli/wiki." >&2
    exit 1
fi

usage () {
# Variables for formatting
U=$(tput smul)  # Underline
RU=$(tput rmul) # Remove underline
B=$(tput bold)  # Bold
N=$(tput sgr0)  # Normal

cat << EOF
                                      __       __         
.--.--.--.-----. ____ .--.--.-----.--|  .---.-|  |_.-----.
|  |  |  |  _  ||____||  |  |  _  |  _  |  _  |   _|  -__|
|________|   __|      |_____|   __|_____|___._|____|_____|
         |__|               |__|                          

${B}Usage:${N}
    
    ${B}$0${N} -p ${U}directory${RU} [-b ${U}directory${RU}] [options]... 

${B}Options:${N}

    ${B}-h${N}  Display this help message

    ${B}-p${N} ${U}directory${RU}    
        Path to WordPress files. This is a required flag.

    ${B}-b${N} ${U}directory${RU}
        Backup WP installation into a ${U}directory${RU} before updating. Backs up
        both the database and files. Will be stored in the following format:

        ${U}directory${RU}
        ├── wp-backup_YYYY-MM-DD_HH:MM:SS
        │   ├── database.sql
        │   └── files.tar.gz
        └── wp-backup...

    ${B}-n${N} ${U}number${RU}
        Number of backups to keep if ${B}-b${N} is specified. Useful to keep the 
        backups directory clean, in case this script is run as a cron job.
        Without this option the script will keep unlimited backups.

    ${B}-w${N}  Generate a wxr (WordPress Extended RSS) file if ${B}-b${N} is specified.
        This file contains all your posts and is useful if you want to
        quickly migrate to wordpress.com. Otherwise it is redundant as the
        ${B}-b${N} option already exports your database.

${B}Examples:${N}

    $0 ${B}-p${N} ${U}/var/www/wp${RU}
        Minimal options. Will update WordPress installation in the specified 
        directory. Will not backup anything, so use at your own risk. Hopefully
        you're using some other backup method.

    $0 ${B}-p${N} ${U}/var/www/wp${RU} ${B}-b${N} ${U}~/backups${RU}
        Recommended command. Will first backup your WordPress installation and
        then update it.

    $0 ${B}-p${N} ${U}/var/www/wp${RU} ${B}-b${N} ${U}~/backups${RU} ${B}-n${N} ${U}5${RU}
        Same as above but now if there are old backups in the backups directory
        the script will clean it up leaving only the 5 most recent ones.
        If there are less than 5 backups, then nothing will happen.

    $0 ${B}-p${N} ${U}.${RU} ${B}-b${N} ${u}backups${RU} ${B}-w${N}
        This will work if the script is in the same directory as wordpress.
        Will also backup a wxr file.

EOF
}

backup () {
    mkdir -p $BACKUP_PATH/wp-backup_$(date +%Y-%m-%d_%T) 
    wp --path=$WP_PATH db export $BACKUP_PATH/wp-backup_$TIMESTAMP/database.sql
    tar czf $BACKUP_PATH/wp-backup_$TIMESTAMP/files.tar.gz $WP_PATH
    if [ $WXR ] ; then
        wp --path=$WP_PATH export --dir=$BACKUP_PATH/wp-backup_$TIMESTAMP/
    fi
}

update () {
    wp --path=$WP_PATH core update
    wp --path=$WP_PATH plugin update --all
    wp --path=$WP_PATH theme update --all
}

cleanup () {
    ls -td $BACKUP_PATH/* | awk -v n=$NUM_OF_BACKUPS 'NR>n' | xargs -r rm -r
}

# Process command line options
while getopts :hp:b:n:w opt; do
    case $opt in
        h) 
            usage 
        ;;
        p) 
            WP_PATH=$OPTARG 
        ;;
        b) 
            BACKUP_PATH=$OPTARG        
            TIMESTAMP=$(date +%Y-%m-%d_%T)
        ;;
        n)
            if [ ! $( echo $OPTARG | egrep ^[[:digit:]]+$ ) ] ; then
                echo "Bad number of backups to keep." >&2
                exit 1
            else
                NUM_OF_BACKUPS=$OPTARG
            fi
        ;;
        w) 
            WXR=true 
        ;;
        ?) 
            echo "Invalid option: -$OPTARG" >&2
            exit 1 
        ;;
        :) 
            echo "Option -$OPTARG requires and arguement" >&2
            exit 1 
        ;;
    esac
done
shift $((OPTIND - 1))

# Run appropriate functions based on options provided
if [ ! $WP_PATH ] ; then
    usage
elif [ $BACKUP_PATH ] && [ ! $NUM_OF_BACKUPS ] ; then
    backup
    update
elif [ $BACKUP_PATH ] && [ $NUM_OF_BACKUPS ] ; then
    backup
    update
    cleanup
else
    update
fi

