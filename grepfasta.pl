#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  grepfasta.pl
#
#        USAGE:  grepfasta.pl [--inverse|-v] [-p='search pattern'|-f=<file with search patterns>] fasta_file
#
#  DESCRIPTION:  Print sequence entry from a fasta file to STDOUT,
#                IF search string match in the definition (header) line.
#                If the '--inverse' option is used, the program prints
#                all sequences except the one for which the match is made.
#                Input search pattern as a search string (--search-pattern),
#                or if multiple searches are to be made, in a file (--search-file),
#                with one search phrase per line.
#                Match must be exact.
#
#      OPTIONS:  See grepfasta.pl -man
# REQUIREMENTS:  Pod::Usage
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Johan A. A. Nylander (JN), <johan.nylander @ nbis.se>
#      COMPANY:  SU
#      VERSION:  1.0
#      CREATED:  03/11/2010 10:34:48 AM CET
#     REVISION:  08/29/2017 01:21:58 PM
#===============================================================================

use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;


## Global parameters
my $man             = 0;
my $help            = 0;
my $inverse         = 0;     # No inverse print by default
my $search_string   = q{};   # Search string
my $search_pattern  = q{};   # Search pattern, with or without single quotes
my $search_file     = q{};   # Search file
my $max             = q{};   # Max nr of matches to print/delete
my $DEBUG           = 0;     # No debug


## Handle arguments
if (@ARGV < 1) {
    die "No arguments. Try:\n\n $0 -man\n\n";
}
else {
    GetOptions('help|?'             => sub { pod2usage(1) },
               'man'                => sub { pod2usage(-exitstatus => 0, -verbose => 2) },
               'v|inverse!'           => \$inverse,
               'p|search-pattern=s' => \$search_pattern,
               'f|search-file=s'    => \$search_file,
               'debug'              => \$DEBUG,
               'n|max=i'            => \$max,
              );#or pod2usage(2)
}



#===  FUNCTION  ================================================================
#         NAME:  trim
#      VERSION:  03/11/2010 10:39:38 AM CET
#  DESCRIPTION:  trim search string
#   PARAMETERS:  string
#      RETURNS:  string
#         TODO:  ???
#===============================================================================
sub trim {

    my ($search_pattern) = @_;

    print STDERR "In function trim(): in >>$search_pattern<<\n" if $DEBUG;

    chomp($search_pattern);
    if ( ($search_pattern =~ m/^'/) and ($search_pattern =~ m/'$/) ) {
        $search_pattern =~ s/^'//;
        $search_pattern =~ s/'$//;
    }

    print STDERR "In function trim(): return >>$search_pattern<<\n" if $DEBUG;

    return($search_pattern);

} # end of trim



#===  FUNCTION  ================================================================
#         NAME:  get_if_match_fasta
#      VERSION:  12/18/2012 05:04:42 PM
#  DESCRIPTION:  print from fasta file if search string match
#   PARAMETERS:  $search_string, $INFILE_file_name
#      RETURNS:  prints to STDOUT
#         TODO:  Debug, match correct?, return? 
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
    ## check if compressed. Warning, does not handle tar archives (*.tar.gz, *.tar.bz2, *.tgz, etc) 
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
    while(<INFILE>) {
        my $line = $_;
        if ($line =~ /^>/) {
            if ($found_match) {
                $found_match = 0;
            }
            $found_separator = 1;
            ## Check header line for match:
            CHECK:
            foreach my $string (@search_strings) {
                if ($line =~ /\Q$string\E/) {
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
#      VERSION:  08/29/2017 01:21:44 PM
#  DESCRIPTION:  Documentation
#         TODO:  ?
#===============================================================================
=pod

=head1 NAME

grepfasta.pl - Get entries from FASTA formatted file based on search in header



=head1 SYNOPSIS

grepfasta.pl [options] file ...



=head1 OPTIONS

=over 8

=item B<-h, -?, --help>

Print a brief help message and exits.

=item B<-m, --man>

Prints the manual page and exits.

=item B<-p, --search-pattern=>I<string>

Supply a search I<string>.

Put separated words (phrases) within single or double quotes (e.g., 'My query').

Match must be exact.

=item B<-f, --search-file=>I<file>

Supply a search I<file> with search strings.

Put several search strings on separate lines.

=item B<-i, --inverse|-v>

Inverse the output, i.e., print all fasta entries except the matching. 

=item B<-n, --max=>I<integer> [NOT IMPLEMENTED]

Print/delete maximum I<integer> matches. Default is to print all.

=item B<-d, --debug>

Do some debug printing.


=back



=head1 DESCRIPTION

B<grepfasta.pl> will search for the presence of I<string> in
the header of a FASTA entry, and print the entry to STDOUT if match
(the default), or print all entries in the file except the match (if
B<--inverse> is used).

The match must be exact (i.e., no regular expressions allowed), and
the search is repeated for each fasta header in the file until EOF.



=head1 USAGE

Examples:

  grepfasta.pl --search-pattern='ABC 123' file.fasta > out.fasta
  grepfasta.pl -p='ABC 123' file.fasta > out.fasta
  grepfasta.pl --search-file=search_file.txt file.fasta > out.fasta
  grepfasta.pl -f=search_file.txt file.fasta > out.fasta
  grepfasta.pl -p='ABC 123' --inverse file.fasta > out.fasta
  grepfasta.pl -p='ABC 123' -v file.fasta > out.fasta
  grepfasta.pl -p='ABC 123' file.fasta.gz > out.fasta


=head1 AUTHOR

Written by Johan A. A. Nylander



=head1 DEPENDENCIES

Uses Perl modules Getopt::Long and Pod::Usage



=head1 LICENSE AND COPYRIGHT

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


=cut

