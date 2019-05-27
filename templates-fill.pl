#!/usr/bin/env perl

use v5.20;
use strict;
use warnings;

use File::Basename;

# @param filename
# @return array reference
sub lines_read {
    open(my $fh, '<', dirname(__FILE__) . '/' . shift) or die "Couldn't open file for reading: $!"; # $! == errno
    my @lines = <$fh>;
    close $fh or die "Couldn't close file from reading: $!";
    \@lines;
}

# @param filename
# @return scalar
sub whole_read {
    open(my $fh, '<', dirname(__FILE__) . '/' . shift) or die "Couldn't open file for reading: $!"; # $! == errno
    local $/;
    my $whole = <$fh>;
    close $fh or die "Couldn't close file from reading: $!";
    $whole;
}

my $tex_header = whole_read 'header.tex';
my $tex_template = whole_read 'template.tex';
my $tex_footer = whole_read 'footer.tex';

my %random_params = ();
$random_params{$_} = lines_read $_ for 'names', 'descriptions', 'essays';

sub template_fill {
    say 'aiyee.';
}

die 'Pass one command line argument (how many applications to generate).' unless @ARGV > 0;
die 'Pass a positive number.' unless $ARGV[0] > 0;
die 'Watch out there, brotha.' if $ARGV[0] > 1000;

print $tex_header;
template_fill for 1..$ARGV[0];
print $tex_footer;
