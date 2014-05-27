#/usr/bin/perl

# Author: David Santiago
# This program is licensed under GPLv3 license
#
# purge Logs  Copyright (C) 2014  David Santiago

use v5.8.8;
use Getopt::Long;

my $logs_dir = '.';

my $lsof = '/usr/sbin/lsof';

GetOptions("lsof=s"=>\$lsof,"dir=s"=>\$logs_dir);


@output = qx '$lsof *';
shift @output; #remove the headers of the lsof output
foreach(@output){
        chomp($line = $_);
        @words = split(' ', $line);
        push @open_files, $words[-1];

}


opendir(DIR, $logs_dir) || die "can't opendir $logs_dir: $!";
@logs = grep { /\.log/ && !/\.gz/ && !/\.bz2/ } readdir(DIR);
closedir DIR;

@hash{@open_files}='1';

@logs = grep { !exists $hash{$_} } @logs;


$command = 'nohup bzip2 '.join(' ', @logs).' &';


system($command);
