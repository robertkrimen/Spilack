package Spilack;

use strict;
use warnings;

use DateTimeX::Easy qw/datetime/;
use Carp;

my $tmp;

sub parse_month {
    my $class = shift;
    my $input = shift;

    my ($month, $year) = $input =~ m/^(\w{3})(\d{2})$/;
    return unless $month = (datetime $month)->month;
    
    return DateTime->new( month => $month, year => 2000 + $year );
}

sub parse {
    my $class = shift;
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

            croak "Unable to parse start $tmp" unless $start = $class->parse_month( $tmp = $start );
            if ( $stop ) {
                croak "Unable to parse stop $tmp" unless $stop = $class->parse_month( $tmp = $stop );
                ( $start, $stop ) = ( $stop, $start ) if $start->epoch > $stop->epoch;
                $stop = $stop->ymd;
            }
            $start = $start->ymd;

#            croak "Unable to parse stop $tmp" if $stop && ! (($stop = datetime( $tmp = $stop )) && $stop = $stop->ymd);
#            croak "Unable to parse start $tmp" unless (($start = datetime( $tmp = $start )) && $start = $start->ymd);
#            croak "Unable to parse stop $tmp" if $stop && ! (($stop = datetime( $tmp = $stop )) && $stop = $stop->ymd);
            
            push @result, { start => $start, stop => $stop, amount => $amount, description => $description };

        }
    }
    return \@result;
}

1;
