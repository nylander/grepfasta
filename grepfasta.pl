#!/usr/bin/env perl

#==================================================================================================
#    USAGE:  grepfasta.pl [options] [-p='search pattern'|-f=<file with search patterns>] fasta_file
#  OPTIONS:  See grepfasta.pl -man
#   AUTHOR:  Johan A. A. Nylander (JN), <johan.nylander @ nrm.se>
#  COMPANY:  NRM
#  VERSION:  1.1.1
#  CREATED:  03/11/2010 10:34:48 AM CET
# REVISION:  ons  4 sep 2024 13:02:41
#==================================================================================================

use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
Getopt::Long::Configure("no_ignore_case", "no_auto_abbrev");


## Global parameters
my $man             = 0;
my $help            = 0;
my $inverse         = 0;       # No inverse print by default
my $search_string   = q{};     # Search string
my $search_pattern  = q{};     # Search pattern, with or without single quotes
my $search_file     = q{};     # Search file
my $max             = -1;      # Max nr of matched seqs to print
my $DEBUG           = 0;       # No debug
my $retval          = 1;       # Return value (0 if any matches)
my $VERSION         = "1.1.1"; # Version


## Handle arguments
if (@ARGV < 1) {
    die "No arguments. Try:\n\n $0 -man\n\n";
}
else {
    GetOptions(
        'h|help|?'           => sub { pod2usage(1) },
        'man'                => sub { pod2usage(-exitstatus => 0, -verbose => 2) },
        'p|search-pattern=s' => \$search_pattern,
        'f|search-file=s'    => \$search_file,
        'v|inverse!'         => \$inverse,
        'n|max:i'            => \$max,
        'debug'              => \$DEBUG,
        'V|version'          => sub { print "$VERSION\n"; exit(0); },
    );
}


#===  FUNCTION  ================================================================
#         NAME:  get_if_match_fasta
#      VERSION:  ons  4 sep 2024 13:30:38
#  DESCRIPTION:  print from fasta file if search string match
#   PARAMETERS:  $search_string, $INFILE_file_name, $file_or_string
#      RETURNS:  prints to STDOUT
#         TODO:  Implement max nr of matched seqs to print
#===============================================================================
sub get_if_match_fasta {

    my ($search, $INFILE_file_name) = @_;

    my @search_strings = ();

    if ($search_file) {
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
                $retval = 0;
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
                        warn "\n >>> search_string $string matches (apparently) on $line (hit return to continue)\n" and getc();
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
                print STDOUT $line unless $inverse;
            }
            elsif ($inverse) {
                print STDOUT $line;
            }
        }
    }

    ## Close file
    close  INFILE
        or warn "$0 : failed to close input file '$INFILE_file_name' : $!\n";

} # end of get_if_match_fasta


#===  FUNCTION  ================================================================
#         NAME:  "MAIN"
#      VERSION:  ons  4 sep 2024 13:41:36
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
exit($retval);


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

=item B<-V, --version>

Print version.


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

Copyright (c) 2009-2024 Johan Nylander

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=head1  DOWNLOAD

L<https://github.com/nylander/grepfasta>


=cut

