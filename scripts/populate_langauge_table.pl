#!/usr/bin/perl -w
# This script populates the language table specified as the first argument.
# The words in the words_file must be separated by newlines.
use strict;
use lib qw(/var/www/lib/perl /home/groups/p/pa/palabra/lib);
use Palabra;

die "USAGE: $0 language words_file\nexample: $0 en_US /usr/share/dict/words\n" unless @ARGV == 2;

my $lang = shift;
my $file = shift;

my $p = Palabra->new();
my $dbh = $p->db_connect();

print $lang, "\n";
open IN, $file or die "Cannot open $file for reading: $!";
# read words and insert them into db
while (<IN>) {
    chomp;
    $dbh->do("INSERT IGNORE INTO $lang (word,language) VALUES(?,?)", undef, $_, $lang);
}
close IN or die "Cannot close $file: $!";

$dbh->disconnect;
