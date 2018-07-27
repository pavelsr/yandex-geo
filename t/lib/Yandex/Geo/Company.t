#!/usr/bin/perl

# perl -Ilib t/lib/Yandex/Geo/Company.t
 
use strict;
use warnings;
use Test::More;
use File::Slurp;

BEGIN { use_ok('Yandex::Geo::Company'); }

my $a = Yandex::Geo::Company->new(
    id => 12345,
    name => 'Romashka LLC',
    phones => [ '+1-541-754-3010', '+49-89-636-48018' ],
    postalCode => 344000,
    url => 'example.com',
    links => [ 'http://foo.bar' ]
);

my $b = [
    12345,
    'Romashka LLC',
    undef,
    '+1-541-754-3010
+49-89-636-48018',
    344000,
    undef,
    'example.com',
    '',
    'http://foo.bar'
];

is ref($a->to_array), 'ARRAY', 'Yandex::Geo::Company/to_array return array';
is_deeply $a->to_array, $b, 'Yandex::Geo::Company/to_array works as documented';

done_testing;