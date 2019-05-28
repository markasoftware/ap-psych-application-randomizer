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
my $application_template = whole_read 'application_template.tex';
my $essay_template = whole_read 'essay_template.tex';
my $tex_footer = whole_read 'footer.tex';

my @names = @{lines_read 'names'};
my @descriptions = @{lines_read 'descriptions'};
my @essays = @{lines_read 'essays'};

# @params a list
# @return randomly selected from the list. Will never return the same element twice in a row!
my $last_pick = -1;
sub pick_rand {
    my $first_pick = int rand scalar @_;
    return pick_rand $@ if $first_pick == $last_pick;
    $last_pick = $first_pick;
    $_[$first_pick];
}

# @param name
# @param description
# @param essay, or undef
# @return filled out template
sub application_template {
    my ($name, $description, $essay) = @_;
    my $filled_essay_template = defined $essay ? $essay_template : '';
    $filled_essay_template =~ s/__ESSAY_QUESTION/$essay/g;

    my $filled_app_template = $application_template;
    my $i = 0;
    while ($filled_app_template =~ /__[A-Z]/) {
        die 'Infinite template detected!' if $i++ > 100;
        $filled_app_template =~ s/__ESSAY_TEMPLATE/$filled_essay_template/g;
        $filled_app_template =~ s/__NAME/$name/g;
        $filled_app_template =~ s/__DESCRIPTION/$description/g;
    }

    $filled_app_template;
}

# @param name1
# @param name2
# @return filled out template
sub choose_template {
     
}

sub application_suite {
    my $essay_fst = int rand 2;
    my ($name1, $name2) = (pick_rand(@names), pick_rand(@names));
    print application_template($name1, pick_rand(@descriptions), $essay_fst ? pick_rand(@essays) : undef);
    print application_template($name2, pick_rand(@descriptions), $essay_fst ? undef : pick_rand(@essays));
    choose_template($name1, $name2);
}

die 'Pass one command line argument (how many applications to generate).' unless @ARGV > 0;
my $suite_count = $ARGV[0];
die 'Pass a positive number.' unless $suite_count > 0;
die 'Watch out there, brotha.' if $suite_count > 1000;

print $tex_header;
application_suite for 1..$suite_count;
print $tex_footer;
