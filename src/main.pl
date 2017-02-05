#!/usr/bin/env perl
use strict;
use warnings;
use Template;
use Text::Markdown qw(markdown);

sub no_intro {
	die("The title must be followed by a level 3 header as intro.");
}

sub no_title {
	die("Markdown document must begin with a level 2 header as title.");
}

if ($#ARGV != 0) {
	print("Usage: main.pl <post.md>\n");
	exit 1;
}

open(my $post, "<", $ARGV[0]) or die("Cannot open \"$ARGV[0]\": $!\n");
my @lines = <$post>;
close($post);

my $check = substr($lines[0], 0, 2);
if ($check cmp "##") {
	no_title();
}

$check = substr($lines[0], 2, 1);
unless ($check cmp "#") {
	no_title();
}

my $cnt = 0;
$check = "";
while ($check =~ /^\s*$/) {
	$cnt++;
	$check = $lines[$cnt];
}

$check = substr($lines[$cnt], 0, 3);
if ($check cmp "###") {
	no_intro();
}

$check = substr($lines[$cnt], 3, 1);
unless ($check cmp "#") {
	no_intro();
}

my $m = Text::Markdown->new;
my $md = "";

foreach (@lines) {
	$md = $md . "\t" . $m->markdown($_) . "\t";
}

# Render the post
my $post_vars = {
	body => $md,
};

my @date = localtime();
my $today = sprintf("%d%02d%02d", $date[5] + 1900, $date[4] + 1, $date[3]);
my $found_path = 0;
my $path = "";
my $stamp = $today; 
$cnt = 1;
until ($found_path) {
	$path = "../site/posts/" . $stamp . ".html";
	if (-e $path) {
		$stamp = $today . "-" . $cnt;
		$cnt++;
	} else {
		$found_path = 1;
	}
}
$path = $stamp . ".html";

my $tt = Template->new({
	INCLUDE_PATH => "../templates/",
	INTERPOLATE => 1,
	OUTPUT_PATH => "../site/posts/",
}) or die("$Template::ERROR\n");

$tt->process("post.html", $post_vars, $path);
