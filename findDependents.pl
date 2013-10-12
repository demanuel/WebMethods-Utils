#/usr/bin/perl

use strict;
use warnings;
use utf8;
use Getopt::Long;

my $help;
my $service;
my $location;
my $disabled;

GetOptions("help"=>\$help,
	   "service=s"=>\$service,
	   "location=s"=>\$location,
	   "disabled"=>\$disabled) or die ("Error in the command line arguments");


sub show_help{

    print <<EOS

Usage: $0 options

This script will search the dependencies of a webmethods service through the file system.

Options:
-h show this message
-s <full.service.FQDN> the service you want to search
-l <path> path in the filesystem to the package folder on the IS installation
-d if you want to find disabled services (-d to search the disabled ones, without -d to search the enabled ones)
EOS

}


sub print_FQDN{

    my ($disabled, $file) = @_;
    
    $file =~ m/.*\/ns\/(.*)\/flow.xml/;
    my $fqdn = $1;
    $fqdn =~ s/\/(?=.*\/)/./g;
    $fqdn =~ s/\//:/g;
    
    
    print "Disabled: " if $disabled == 0;
    print "Enabled: " if $disabled == 1;
    print "$fqdn\n";

}

sub check_invocations{

    my ($file, $service, $disabled) = @_;
    
    $service="SERVICE=\"$service\"";

    open my $fh, '<', $file or die $!;

    while(<$fh>){

	my $string =$_;
	if(index($string,$service)!=-1){
#	    print "MATCH= $file\n";

	    if($disabled){
		if(index($string, "DISABLED=\"true\"")!= -1){
		    print_FQDN 0, $file;
		    last;
		}
	    }
	    elsif(index($string, "DISABLED=\"true\"")== -1 ){

		print_FQDN 1, $file;
		last;
	    }
	}
    }

    close $fh;
}

sub find_dependencies{
    
    my ($location, $service, $disabled) = @_;

    my @files = ();
    if(-f $location){

	if(substr($location, -8) eq 'flow.xml'){
	    check_invocations $location, $service, $disabled;
	}
	return ($location)
     }
    else{
	if(-d $location){
	    opendir my $dh, $location  or die;
	    while(my $file = readdir $dh){
		chomp($file);
		if($file ne "." && $file ne ".."){
		    my $new_file = "$location/$file";
		    push @files, find_dependencies($new_file, $service, $disabled) ;
		}
	    }
	    close $dh;
	    return @files;

	}
	return ();

    }
}


if ($help || (!defined $service || !defined $location)) {
    show_help();
    exit 0;
}

#print "deopis";
find_dependencies $location, $service, $disabled;



