package Spilack;

use strict;
use warnings;

use DateTimeX::Easy qw/datetime/;
use DBIx::SQLite::Deploy;
use Carp;

my $tmp;

sub _parse_month {
    my $class = shift;
    my $input = shift;

    my ($month, $year) = $input =~ m/^(\w{3})(\d{2})$/;
    return unless $month = (datetime $month)->month;
    
    return DateTime->new( month => $month, year => 2000 + $year );
}

sub parse {
    my $class = shift;
    my $input = shift;

    my @output;
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

            croak "Unable to parse start $tmp" unless $start = $class->_parse_month( $tmp = $start );
            if ( $stop ) {
                croak "Unable to parse stop $tmp" unless $stop = $class->_parse_month( $tmp = $stop );
                ( $start, $stop ) = ( $stop, $start ) if $start->epoch > $stop->epoch;
                $stop = $stop->ymd;
            }
            $start = $start->ymd;

#            croak "Unable to parse stop $tmp" if $stop && ! (($stop = datetime( $tmp = $stop )) && $stop = $stop->ymd);
#            croak "Unable to parse start $tmp" unless (($start = datetime( $tmp = $start )) && $start = $start->ymd);
#            croak "Unable to parse stop $tmp" if $stop && ! (($stop = datetime( $tmp = $stop )) && $stop = $stop->ymd);
            
            push @output, { category => $category, start => $start, stop => $stop, amount => $amount, description => $description };

        }
    }

    return \@output;
}

sub _deploy {
    my $class = shift;

    my $file = 'spilack.sqlite';
    unlink $file;
    my $deploy = DBIx::SQLite::Deploy->deploy( $file => <<_END_ );
[% PRIMARY_KEY = "INTEGER PRIMARY KEY AUTOINCREMENT" %]
[% CLEAR %]
---
CREATE TABLE payment (

    id                  [% PRIMARY_KEY %],

    category            TEXT,
    month               DATE,
    amount              INTEGER,
    description         TEXT
);
_END_

    return $deploy;
}

sub _unroll {
    my $class = shift;
    my $input = shift;

    $input = $class->parse( $input );

    my @output;

    for my $entry (@$input) {
        my ( $start, $stop, $category, $amount, $description ) = @$entry{qw/ start stop category amount description /};
        $amount *= 100;

        $stop = $start unless $stop;

        ( $start, $stop ) = ( datetime( $start ), datetime( $stop ) );
        my $cursor = $start->clone;
        while ( 1 ) {
            push @output, { category => $category, month => $cursor->ymd, amount => $amount, description => $description };
            last if $cursor->ymd eq $stop->ymd;
            $cursor->add( months => 1 );
        }
    }

    return \@output;
}

sub load {
    my $class = shift;
    my $input = shift;

    my $deploy = $class->_deploy;
}

sub tally {
    my $class = shift;
    my $input = shift;

    $input = $class->_unroll( $input );

    my %tally;

    for my $entry (@$input) {
        my ( $category, $amount, $description ) = @$entry{qw/ category amount description /};
        my $sum = $tally{ $description} ||= { description => $description, amount => 0, category => $category };
        $sum->{amount} += $amount;
    }

    return \%tally;
}

1;
