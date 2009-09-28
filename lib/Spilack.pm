package Spilack;

use strict;
use warnings;

use DateTimeX::Easy qw/datetime/;

sub parse {
    shift;
    my $input = shift;

    my @result;
    my $category = '';
    for (split m/\n/, $input) {

        next if m/^\s*$/;
        next if m/^\s*#/;
        
        if (m/^\s*category:\s*(.*)/) {
            $category = $1;
        }
        else {
            my ($range, $amount, $description) = split m/\s+/, $_, 3;
            my ($start, $stop) = $range =~ m/^(\w{3}\d{2})(?:\s*-\s*(\w{3}\d{2}))?$/;
            
            push @result, { start => $start, stop => $stop, amount => $amount, description => $description };

        }
    }
    return \@result;
}

1;
