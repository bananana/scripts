#!/usr/bin/env python3

import argparse
import urllib.request
from urllib.parse import urlparse
from html.parser import HTMLParser


class ExtractLinks(HTMLParser):
    """ Use HTMLParser to extract links from input.

    Extend HTMLParser to handle specific tags and parameters as well as
    store and return the links that it finds. 
    
    After creating the object you have to feed it the html as a string 
    like so: `object_name.feed(html)`. This runs the `handle_starttag()`
    function and stores the results in self.found_links list.
    """
    def __init__(self):
        """ Overload the default HTMLParser constructor.
        
        Attributes:
            found_links (list): holds whatever links are found 
                using the .feed() function. 
            
            tags_to_process (dict): a dict of key-value pairs corresponding
                to tag and its respective parameter that should hold a link.
        """
        super(ExtractLinks, self).__init__()
        self.found_links = []
        self.tags_to_process = {'a':'href', 
                                'img':'src', 
                                'script':'src', 
                                'link':'href'}
    def handle_starttag(self, tag, attrs):
        """ Go through all the tags in an html document and get links using
        the `tags_to_process` dict as reference.
        """
        for t, n in self.tags_to_process.items():
            if tag == t:
                for name, value in attrs:
                    if name == n and value and value != '#' \
                       and 'javascript:' not in value:
                        # Append only non empty parameters 
                        # (`#` and `javascript` are considered empty)
                        self.found_links.append(value)
    def get_unique_links(self):
        """ Return list of links without duplicates.
        """
        return list(set(self.found_links))

# Create the HTMLParser object right away
extractor = ExtractLinks()


# Setup argparse
parser = argparse.ArgumentParser(description='Extract links from target html')
parser.add_argument('-f', 
                    '--file', 
                    help='extract from a file on local computer')
parser.add_argument('-u',
                    '--url',
                    help='extract from a remote url')
args = parser.parse_args()


# Handle all the command line options
if args.file:
    try:
        with open(args.file, mode='r') as f:
            extractor.feed(f.read())
            for l in extractor.get_unique_links():
                print(l)
            f.close()
    except FileNotFoundError:
        print('%s: No such file or directory' % args.file)

elif args.url:
    # Add protocol if none is provided, otherwise urllib will give an error
    if 'http' not in args.url:
        args.url = 'http://' + args.url

    # Get the domain name
    parsed_uri = urlparse(args.url)
    domain = '{uri.scheme}://{uri.netloc}'.format(uri=parsed_uri)

    try:
        with urllib.request.urlopen(args.url) as response:
            extractor.feed(str(response.read()))
            for l in extractor.get_unique_links():
                if l[0:2] == '//':
                    # Protocol relative url found
                    print(parsed_uri.scheme + ':' + l)
                if l[0] == '/':
                    # Link relative to root found
                    print(domain + l)
                elif 'http' not in l and l[0] != '/':
                    # Link relative to current location found
                    print(domain + '/' + l)
                else:
                    # Absolute link found, just print it
                    print(l)
    except ValueError:
        print('%s: Unknown url type' % args.url)
    except urllib.error.HTTPError as e:
        print(str(e))

else:
    parser.print_help()
