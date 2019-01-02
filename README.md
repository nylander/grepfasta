# NAME

grepfasta.pl - Get entries from FASTA formatted file based on search in header

# SYNOPSIS

    grepfasta.pl [options] -p 'pattern' file 

# DESCRIPTION

**grepfasta.pl** will search for the presence of _string_ in
the header of a FASTA entry, and print the entry to STDOUT if 
a match is found, or print all entries in the file except the
match (if **--inverse** is used).

The search pattern can be a regular expression (Perl), and can
be supplied on command line, or in a file.

If several patterns are given in the search file, all of them are
used for matching on all fasta entries.

The search is repeated for each fasta header in the file until EOF,
unless the **--max** option is used. The **--max** option only limits
the total number of sequences to print, which may be important
to consider if several search patterns are used in a search file.

The script can read compressed fasta files (.gz, .zip, .Z, .bz2),
if gzip and/or bunzip2 are available.

# OPTIONS

- **-h, -?, --help**

    Print a brief help message and exits.

- **-m, --man**

    Prints the manual page and exits.

- **-p, --search-pattern=**_string_

    Supply a search _string_.

    Put separated words (phrases) within single or double quotes (e.g., 'My query').

    Search string may be a regular expression (Perl).

- **-f, --search-file=**_file_

    Supply a search _file_ with search strings.

    Put several search strings on separate lines.

- **-i, --inverse|-v**

    Inverse the output, i.e., print all fasta entries except the matching. 

- **--max=_integer_|-n**

    Maximum number of sequences to print. Default: all matches.

- **-d, --debug**

    Do some debug printing.

# USAGE

Examples:

    grepfasta.pl --search-pattern='ABC 12' data/file.fasta
    grepfasta.pl -p='ABC 12' data/file.fasta

    grepfasta.pl --search-file=data/search_file.txt data/file.fasta
    grepfasta.pl -f=data/search_file.txt data/file.fasta

    grepfasta.pl -p='ABC 12' --inverse data/file.fasta
    grepfasta.pl -p='ABC 12' -v data/file.fasta

    grepfasta.pl -p='ABC 12' data/file.fasta.gz

    grepfasta.pl -p='ABC 3' data/file.fasta
    grepfasta.pl -p='ABC 3' --max=1 data/file.fasta

    grepfasta.pl -p='ABC 1' data/file.fasta
    grepfasta.pl -p='1$' data/file.fasta
    grepfasta.pl -p='\w+\s+\d{2}$' data/file.fasta
    grepfasta.pl -p='[a-z]+\s+\d{2}$' data/file.fasta
    grepfasta.pl -p='^>[a-z]+\s+\d{2}$' data/file.fasta

# DEPENDENCIES

Uses Perl modules Getopt::Long and Pod::Usage for documentation,
and gzip/bzip2 for uncompressing.

# AUTHOR

Written by Johan A. A. Nylander

# LICENSE AND COPYRIGHT

Copyright (c) 2009-2019 Johan Nylander. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details. 
http://www.gnu.org/copyleft/gpl.html 

# DOWNLOAD

[https://github.com/nylander/grepfasta](https://github.com/nylander/grepfasta)
