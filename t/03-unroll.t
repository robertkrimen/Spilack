#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use Spilack;

my $input;

$input = <<_END_;
Jan01 1 Alice
Jan01-Jun01 2 Bob not Alice
#Aug04-Jun03 3 Charlie
_END_
cmp_deeply( Spilack->_unroll( $input ), [
    { qw/ month 2001-01-01 amount 1/, description => 'Alice', category => '', },
    { qw/ month 2001-01-01 amount 2/, description => 'Bob not Alice', category => '', },
    { qw/ month 2001-02-01 amount 2/, description => 'Bob not Alice', category => '', },
    { qw/ month 2001-03-01 amount 2/, description => 'Bob not Alice', category => '', },
    { qw/ month 2001-04-01 amount 2/, description => 'Bob not Alice', category => '', },
    { qw/ month 2001-05-01 amount 2/, description => 'Bob not Alice', category => '', },
    { qw/ month 2001-06-01 amount 2/, description => 'Bob not Alice', category => '', },
] );
#    {qw/ start 2003-06-01 stop 2004-08-01 amount 3/, description => 'Charlie', },

