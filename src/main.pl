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
if ($#ARGV != 0) {
	print("Usage: main.pl <post.md>\n");
	exit 1;
}

# Read outmarkdown document
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
	$md = $md . "\t" . $m->markdown($_) . "\t\t";
}

# Find an appropriate filepath for the new post
my $post_vars = {
	content => $md,
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

# Initialise the template engine and write out the new post
my $tt = Template->new({
	INCLUDE_PATH => "../templates/",
	INTERPOLATE => 1,
	OUTPUT_PATH => "../site/posts/",
}) or die("$Template::ERROR\n");
$tt->process("post.html", $post_vars, $path);

# Get the filenames of the last 5 posts
opendir(my $posts_dir, "../site/posts/") or die("Couldn't open directory: $!\n");
my @posts = readdir($posts_dir);
closedir($posts_dir);
@posts = @posts[($#posts-5)..$#posts];


# Populate arrays with titles and intros from last 5 posts
my @titles;
my @intros;
foreach (@posts) {	
	my $parser = HTML::TokeParser->new(
		"../site/posts/" . $_) or die("$!\n");
	$parser->get_tag("h2");
	push(@titles, $parser->get_text("/h2"));
	$parser->get_tag("h3");
	push(@intros, $parser->get_text("/h3"));
}
for ($cnt = 0; $cnt < $#titles; $cnt++) {
	print("$titles[$cnt]: $intros[$cnt]\n");
}
