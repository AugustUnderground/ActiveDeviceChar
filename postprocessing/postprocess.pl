#!/usr/bin/perl

my $infile = $ARGV[0];

open (INFILE, "<", $infile) or die "could not open:$!";

while (my $line = <INFILE>)
{
    $line =~s/\@m\S+\[(\S+)\]/$1/g;
    $line =~s/^\s+//g;
    $line =~s/\s+$//g;
    $line =~s/\s+/,/g;

    print STDOUT "$line\n";
}

close (INFILE);
