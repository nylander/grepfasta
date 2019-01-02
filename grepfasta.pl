#!/usr/bin/env perl 

#===============================================================================
#    USAGE:  grepfasta.pl [options] [-p='search pattern'|-f=<file with search patterns>] fasta_file
#  OPTIONS:  See grepfasta.pl -man
#   AUTHOR:  Johan A. A. Nylander (JN), <johan.nylander @ nbis.se>
#  COMPANY:  NRM/NBIS
#  VERSION:  1.1
#  CREATED:  03/11/2010 10:34:48 AM CET
# REVISION:  Wed 02 Jan 2019 02:42:04 PM CET
#===============================================================================

use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;


## Global parameters
my $man             = 0;
my $help            = 0;
my $inverse         = 0;     # No inverse print by default
my $search_string   = q{};   # Search string
my $search_pattern  = q{};   # Search pattern, with or without single quotes
my $search_file     = q{};   # Search file
my $max             = -1;    # Max nr of matched seqs to print
my $DEBUG           = 0;     # No debug


## Handle arguments
if (@ARGV < 1) {
    die "No arguments. Try:\n\n $0 -man\n\n";
}
else {
    GetOptions('help|?'             => sub { pod2usage(1) },
               'man'                => sub { pod2usage(-exitstatus => 0, -verbose => 2) },
               'p|search-pattern=s' => \$search_pattern,
               'f|search-file=s'    => \$search_file,
               'v|inverse!'         => \$inverse,
               'n|max:i'            => \$max,
               'debug'              => \$DEBUG,
              );
}


#===  FUNCTION  ================================================================
#         NAME:  get_if_match_fasta
#      VERSION:  Wed 02 Jan 2019 03:51:51 PM CET
#  DESCRIPTION:  print from fasta file if search string match
#   PARAMETERS:  $search_string, $INFILE_file_name
#      RETURNS:  prints to STDOUT
#         TODO:  Implement max nr of matched seqs to print
#===============================================================================
sub get_if_match_fasta {

    my ($search, $INFILE_file_name) = @_;

    my @search_strings = ();

    if ( -e $search ) { # is $search a file?
        ## Search file
        open my $SF, "<", $search or die "could not open file $search : $! \n";
        while(<$SF>) {
            chomp($_);
            next if /^\s*$/;
            push(@search_strings, $_);
        }
        close($SF);
    }
    else {
        push(@search_strings, $search);
    }

    ## Get file name
    if ($INFILE_file_name =~ /\.gz$/) {
        $INFILE_file_name =~ s/(.*\.gz)\s*$/gzip -dc < $1|/;
    }
    elsif ($INFILE_file_name =~ /\.zip$/) {
        $INFILE_file_name =~ s/(.*\.zip)\s*$/gzip -dc < $1|/;
    }
    elsif ($INFILE_file_name =~ /\.Z$/) {
        $INFILE_file_name =~ s/(.*\.Z)\s*$/gzip -dc < $1|/;
    }
    elsif ($INFILE_file_name =~ /\.bz2$/) {
        $INFILE_file_name =~ s/(.*\.bz2)\s*$/bzip2 -dc < $1|/;
    }
    open(INFILE, $INFILE_file_name)
        or die  "$0 : failed to open  input file '$INFILE_file_name' : $! \n";

    ## Set some start values
    my $found_empty_line = 0;
    my $found_fasta_line = 0;
    my $found_separator = 0;
    my $found_match = 0;
    my $counter = 0;

    ## Read the file
    READFILE:
    while(<INFILE>) {
        my $line = $_;
        if ($line =~ /^>/) {
            if ($found_match) {
                if ($counter == $max) {
                    last READFILE;
                }
                $found_match = 0;
            }
            $found_separator = 1;
            ## Check header line for match:
            CHECK:
            foreach my $string (@search_strings) {
                if ($line =~ /$string/) {
                    if ($DEBUG) {
                        warn "\n >>> search_string $string matches (apparently) on $line(hit return to continue)\n" and getc();
                    }
                    $found_match = 1;
                    $counter++;
                    last CHECK;
                }
            }
            if ($found_match) {
                print STDOUT $line unless $inverse;
            }
            elsif ($inverse) {
                print STDOUT "$line";
            }
        }
        else {
            if ($found_match) {
                print STDOUT  $line unless $inverse;
            }
            elsif ($inverse) {
                print STDOUT  $line;
            }
        }
    }

    ## Close file
    close  INFILE
        or warn "$0 : failed to close input file '$INFILE_file_name' : $!\n";

} # end of get_if_match_fasta


#===  FUNCTION  ================================================================
#         NAME:  "MAIN"
#      VERSION:  03/11/2010 10:34:07 AM CET
#  DESCRIPTION:  ???
#   PARAMETERS:  ???
#      RETURNS:  ???
#         TODO:  ???
#===============================================================================
MAIN:
while (my $INFILE_file_name = shift(@ARGV)) {
    if ($search_pattern) {
        get_if_match_fasta($search_pattern, $INFILE_file_name);
    }
    elsif ($search_file) {
        get_if_match_fasta($search_file, $INFILE_file_name);
    }
    else {
        print STDERR "Error. No search pattern/file given.\n";
        exit(1);
    }
}
exit(0);


__END__


#===  POD DOCUMENTATION  =======================================================
#      VERSION:  Wed 02 Jan 2019 02:48:14 PM CET
#  DESCRIPTION:  Documentation
#         TODO:  ?
#===============================================================================
=pod

=head1 NAME

grepfasta.pl - Get entries from FASTA formatted file based on search in header


=head1 SYNOPSIS

grepfasta.pl [options] -p 'pattern' file 


=head1 DESCRIPTION

B<grepfasta.pl> will search for the presence of I<string> in
the header of a FASTA entry, and print the entry to STDOUT if 
a match is found, or print all entries in the file except the
match (if B<--inverse> is used).

The search pattern can be a regular expression (Perl), and can
be supplied on command line, or in a file.

If several patterns are given in the search file, all of them are
used for matching on all fasta entries.

The search is repeated for each fasta header in the file until EOF,
unless the B<--max> option is used. The B<--max> option only limits
the total number of sequences to print, which may be important
to consider if several search patterns are used in a search file.

The script can read compressed fasta files (.gz, .zip, .Z, .bz2),
if gzip and/or bunzip2 are available.


=head1 OPTIONS

=over 8

=item B<-h, -?, --help>

Print a brief help message and exits.

=item B<-m, --man>

Prints the manual page and exits.

=item B<-p, --search-pattern=>I<string>

Supply a search I<string>.

Put separated words (phrases) within single or double quotes (e.g., 'My query').

Search string may be a regular expression (Perl).

=item B<-f, --search-file=>I<file>

Supply a search I<file> with search strings.

Put several search strings on separate lines.

=item B<-i, --inverse|-v>

Inverse the output, i.e., print all fasta entries except the matching. 

=item B<--max=I<integer>|-n>

Maximum number of sequences to print. Default: all matches.

=item B<-d, --debug>

Do some debug printing.

=back


=head1 USAGE

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


=head1 DEPENDENCIES

Uses Perl modules Getopt::Long and Pod::Usage for documentation,
and gzip/bzip2 for uncompressing.


=head1 AUTHOR

Written by Johan A. A. Nylander


=head1 LICENSE AND COPYRIGHT

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


=head1  DOWNLOAD

L<https://github.com/nylander/grepfasta>


=cut

