# scripts
A collection of my scripts.

## extract_links.py
A simple script to extract links from an html file. Either on a local machine or from a remote URL.

    usage: extract_links.py [-h] [-f FILE] [-u URL]

    Extract links from target html

    optional arguments:
      -h, --help            show this help message and exit
      -f FILE, --file FILE  extract from a file on local computer
      -u URL, --url URL     extract from a remote url

Best used in combination with grep and wget (or curl) to mass download files. For example:

    ./extract_links.py -u somesite.com | grep jpg | xargs -L 1 wget

The above command downloads all jpg files form a given URL.

## wp-update.sh
A script to update and/or backup a WordPress using [wp-cli](http://wp-cli.org/). The backups include a copy of the database and compressed files.

```
                                      __       __         
.--.--.--.-----. ____ .--.--.-----.--|  .---.-|  |_.-----.
|  |  |  |  _  ||____||  |  |  _  |  _  |  _  |   _|  -__|
|________|   __|      |_____|   __|_____|___._|____|_____|
         |__|               |__|                          

Usage:
    
    ./wp-update.sh -p directory [-b directory] [options]... 

Options:

    -h  Display this help message

    -p directory    
        Path to WordPress files. This is a required flag.

    -b directory
        Backup WP installation into a directory before updating. Backs up
        both the database and files. Will be stored in the following format:

        directory
        ├── wp-backup_YYYY-MM-DD_HH:MM:SS
        │   ├── database.sql
        │   └── files.tar.gz
        └── wp-backup...

    -n number
        Number of backups to keep if -b is specified. Useful to keep the 
        backups directory clean, in case this script is run as a cron job.
        Without this option the script will keep unlimited backups.

    -w  Generate a wxr (WordPress Extended RSS) file if -b is specified.
        This file contains all your posts and is useful if you want to
        quickly migrate to wordpress.com. Otherwise it is redundant as the
        -b option already exports your database.

Examples:

    ./wp-update.sh -p /var/www/wp
        Minimal options. Will update WordPress installation in the specified 
        directory. Will not backup anything, so use at your own risk. Hopefully
        you're using some other backup method.

    ./wp-update.sh -p /var/www/wp -b ~/backups
        Recommended command. Will first backup your WordPress installation and
        then update it.

    ./wp-update.sh -p /var/www/wp -b ~/backups -n 5
        Same as above but now if there are old backups in the backups directory
        the script will clean it up leaving only the 5 most recent ones.
        If there are less than 5 backups, then nothing will happen.

    ./wp-update.sh -p . -b ${u}backups -w
        This will work if the script is in the same directory as wordpress.
        Will also backup a wxr file.
```
