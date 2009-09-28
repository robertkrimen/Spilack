#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use Spilack;

my $input;

$input = <<_END_;
Jan01 1 Alice
Jan01-Jun03 2 Bob not Alice
_END_
cmp_deeply( Spilack->parse( $input ), [
    {qw/ start Jan01 amount 1/, description => 'Alice', stop => undef },
    {qw/ start Jan01 stop Jun03 amount 2/, description => 'Bob not Alice', },
] );
