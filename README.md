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

The example above downloads all jpg files form a given URL.
