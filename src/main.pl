#!/usr/bin/env perl
use strict;
use warnings;
use Template;
use Text::Markdown qw(markdown);

sub no_heading {
	die("Markdown document must begin with a level 1 header.");
}

if ($#ARGV != 0) {
	print("Usage: main.pl <post.md>\n");
	exit 1;
}

open(my $post, "<", $ARGV[0]) or die("Cannot open \"$ARGV[0]\": $!\n");
my @lines = <$post>;
close($post);

my $check = substr($lines[0], 0, 1);
if ($check cmp "#") {
	no_heading();
}

$check = substr($lines[0], 1, 1);
unless ($check cmp "#") {
	no_heading();
}

my $m = Text::Markdown->new;
my @md;

foreach (@lines) {
	push(@md, $m->markdown($_));
}

my $md_str = "";
foreach (@md) {
	$md_str = $md_str . "\t" . $_ . "\t";
}

my $post_vars = {
	body => $md_str,
};

my @date = localtime();
my $today = sprintf("%d%02d%02d", $date[5] + 1900, $date[4] + 1, $date[3]);

my $found_path = 0;
my $path = "";
my $stamp = $today; 
my $cnt = 0;
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
print($path);
my $tt = Template->new({
	INCLUDE_PATH => "../templates/",
	INTERPOLATE => 1,
	OUTPUT_PATH => "../site/posts/",
}) or die("$Template::ERROR\n");

$tt->process("post.html", $post_vars, $path);

