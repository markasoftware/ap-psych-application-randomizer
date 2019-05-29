#!/usr/bin/env perl

use v5.20;
use strict;
use warnings;

use File::Basename;

# @param filename
# @return array reference
sub lines_read {
    my $fname = shift;
    open(my $fh, '<', dirname(__FILE__) . '/' . $fname) or die "Couldn't open file $fname for reading: $!"; # $! == errno
    my @lines = <$fh>;
    chomp @lines;
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
my $choose_template = whole_read 'choose_template.tex';
my $tex_footer = whole_read 'footer.tex';

my %lines_generics = ();
my @names = @{lines_read "names"};

my @auto_template_keys = ("essay_question", "description", "list_instruction", "fillin_instruction");

# @param the key to prevent double picks by
# @params a list
# @return randomly selected from the list. Will never return the same element twice in a row!
my %last_picks = ();
sub pick_rand {
    my $pick_key = shift;
    $last_picks{$pick_key} //= -1;
    my $last_pick_ref = \$last_picks{$pick_key};
    my $last_pick = ${$last_pick_ref};
    my $pick = $last_pick;
    $pick = int rand scalar @_ while $pick == $last_pick;
    ${$last_pick_ref} = $pick;
    $_[$pick];
}

# destroy the uniqueness property of pick_rand. Call in-between applications
# @param the key to zap
sub zap_rand {
    # shift doesn't work here for some reason
    $last_picks{$_[0]} = -1;
}

# @param $template
# @param %replacements (__NAME => $name) for example
# @returned filled template
sub fill_template {
    my $template = shift;
    my %replacements = @_;
    my $i = 0;
    while ($template =~ /__[A-Z]/) {
        die "Infinite template detected! $template" if $i++ > 100;
        $template =~ s/$_/$replacements{$_}/g for keys %replacements;
    }
    $template;
}

# @param name
# @param description
# @param student ID
# @param essay, or undef
# @return filled out template
sub application_template {
    my ($name, $sid, $essay_should) = @_;
    my $essay_template = $essay_should ? $essay_template : '';
    my %template_params = ();
    for (@auto_template_keys) {
        $lines_generics{$_} //= lines_read($_ . 's');
        $template_params{'__' . uc} = pick_rand($_, @{${lines_generics{$_}}});
    }

    fill_template($application_template,
                  __ESSAY_TEMPLATE => $essay_template,
                  __ID => $sid,
                  __NAME => $name,
                  %template_params);
}

# @param name1
# @param name2
# @return filled out template
sub choose_template {
    fill_template($choose_template,
                  __NAME_1 => shift,
                  __NAME_2 => shift);
}

sub application_suite {
    my $essay_fst = int rand 2;
    my $sid = 1e7 + int rand 9e7;
    my ($name1, $name2) = (pick_rand("name", @names), pick_rand("name", @names));
    say application_template($name1, $sid, $essay_fst);
    say application_template($name2, $sid, not $essay_fst);
    say choose_template($name1, $name2);
    zap_rand $_ for @auto_template_keys, "description";
}

die 'Pass one command line argument (how many applications to generate).' unless @ARGV > 0;
my $suite_count = $ARGV[0];
die 'Pass a positive number.' unless $suite_count > 0;
die 'Watch out there, brotha.' if $suite_count > 1000;

print $tex_header;
application_suite for 1..$suite_count;
print $tex_footer;
