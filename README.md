# NAME

grepfasta.pl - Get entries from FASTA formatted file based on search in header

# SYNOPSIS

grepfasta.pl \[options\] file ...

# OPTIONS

- **-h, -?, --help**

    Print a brief help message and exits.

- **-m, --man**

    Prints the manual page and exits.

- **-p, --search-pattern=**_string_

    Supply a search _string_.

    Put separated words (phrases) within single or double quotes (e.g., 'My query').

    Match must be exact.

- **-f, --search-file=**_file_

    Supply a search _file_ with search strings.

    Put several search strings on separate lines.

- **-i, --inverse|-v**

    Inverse the output, i.e., print all fasta entries except the matching. 

- **-n, --max=**_integer_ \[NOT IMPLEMENTED\]

    Print/delete maximum _integer_ matches. Default is to print all.

- **-d, --debug**

    Do some debug printing.

# DESCRIPTION

**grepfasta.pl** will search for the presence of _string_ in
the header of a FASTA entry, and print the entry to STDOUT if match
(the default), or print all entries in the file except the match (if
**--inverse** is used).

The match must be exact (i.e., no regular expressions allowed), and
the search is repeated for each fasta header in the file until EOF.

# USAGE

Examples:

    grepfasta.pl --search-pattern='ABC 123' file.fasta > out.fasta
    grepfasta.pl -p='ABC 123' file.fasta > out.fasta
    grepfasta.pl --search-file=search_file.txt file.fasta > out.fasta
    grepfasta.pl -f=search_file.txt file.fasta > out.fasta
    grepfasta.pl -p='ABC 123' --inverse file.fasta > out.fasta
    grepfasta.pl -p='ABC 123' -v file.fasta > out.fasta
    grepfasta.pl -p='ABC 123' file.fasta.gz > out.fasta

# AUTHOR

Written by Johan A. A. Nylander

# DEPENDENCIES

Uses Perl modules Getopt::Long and Pod::Usage

# LICENSE AND COPYRIGHT

Copyright (c) 2009,2010,2011,2012,2013,2014,2015,2016,2017 Johan Nylander. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details. 
http://www.gnu.org/copyleft/gpl.html 
