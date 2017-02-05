#!/usr/bin/env perl
use strict;
use warnings;

sub no_heading {
	die("Markdown doucment must begin with a level 1 header.");
}

if ($#ARGV != 0) {
	print("Usage: main.pl <post.md>\n");
	exit 1;
}

open(FILE, "<", $ARGV[0]) or die("Cannot open \"$ARGV[0]\": $!\n");
my @lines = <FILE>;
close(FILE);

my $check = substr($lines[0], 0, 1);
if ($check cmp "#") {
	no_heading();
}

$check = substr($lines[0], 1, 1);
unless ($check cmp "#") {
	no_heading();
}

