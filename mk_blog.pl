#!/usr/bin/env perl
use strict;
use warnings;
use HTML::TokeParser; 
use Template;
use Text::Markdown qw(markdown);

sub no_intro {
	die("The title must be followed by a level 3 header as intro.");
}

sub no_title {
	die("Markdown document must begin with a level 2 header as title.");
}

# Correct arguments?
if ($#ARGV != 2) {
	print("Usage: main.pl <post.md> <site_root> <template_dir>\n");
	exit 1;
}

# Check that template_dir exists and contains expected files
if (-d $ARGV[2]) {
	my @templates = ("/front.html", "/list.html", "/post.html");
	foreach (@templates) {
		unless(-e $ARGV[2] . $_) {
			die("Mising $_ template.\n");
		}
	}
} else {
	die("Invalid template_dir\n");
}

# Check that site_root exists
unless (-d $ARGV[1]) {
	die("Invalid site_root\n");
}

# Read in markdown document
open(my $post, "<", $ARGV[0]) or die("Cannot open \"$ARGV[0]\": $!\n");
my @lines = <$post>;
close($post);

# Check the first line is a title
my $check = substr($lines[0], 0, 2);
if ($check cmp "##") {
	no_title();
}
$check = substr($lines[0], 2, 1);
unless ($check cmp "#") {
	no_title();
}

# Check that the next non-blank line is an intro
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

# Render the post into one long string of HTML
my $m = Text::Markdown->new;
my $md = "";
foreach (@lines) {
	$md = $md . $m->markdown($_) . "\t\t";
}

# Find an appropriate filepath for the new post
my $vars = { content => $md, };
my @date = localtime();
my $today = sprintf("%d%02d%02d", $date[5] + 1900, $date[4] + 1, $date[3]);
my $found_path = 0;
my $path = "";
my $stamp = $today; 
$cnt = 1;
unless (-d $ARGV[1] . "/posts") {
	mkdir($ARGV[1] . "/posts") or die("$!\n");
}
until ($found_path) {
	$path = $ARGV[1] . "/posts/" . $stamp . ".html";
	if (-e $path) {
		$stamp = $today . "-" . $cnt;
		$cnt++;
	} else {
		$found_path = 1;
	}
}
$path = "/posts/" . $stamp . ".html";

# Initialise the template engine and write out the new post
my $tt = Template->new({
	INCLUDE_PATH =>  $ARGV[2] . "/",
	INTERPOLATE => 0,
	OUTPUT_PATH => $ARGV[1],
}) or die("$Template::ERROR\n");
$tt->process("post.html", $vars, $path) or die("$tt->error()\n");

# Get the filenames of all previous posts
opendir(my $posts_dir, $ARGV[1] . "/posts/") 
	or die("Couldn't open directory: $!\n");
my @posts = readdir($posts_dir);
closedir($posts_dir);

# Populate array with titles and intros
my @front_matter;
foreach (@posts) {	
	unless ($_ eq "index.html" || $_ eq "." || $_ eq "..") {
		my $parser = HTML::TokeParser->new(
			$ARGV[1] . "/posts/" . $_) or die("$!\n");
		$parser->get_tag("h2");
		my $title = $parser->get_text("/h2");
		$parser->get_tag("h3");
		my $intro = $parser->get_text("/h3");
		push(@front_matter, 
			{ title => $title, intro => $intro, href => $_, });
	}
}
$vars = { content => \@front_matter, };

# Write out post listing
$tt->process("list.html", $vars, "/posts/index.html") 
	or die("$tt->error()\n");

# If possible truncate front page to a list of 5 posts, then write it out
if ($#front_matter >= 4) {
	@front_matter = @front_matter[($#front_matter-4)..$#front_matter];
	$vars = { content => \@front_matter, };
}
$tt->process("front.html", $vars, "/index.html") 
	or die("$tt->error()\n");
