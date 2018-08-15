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

my @all = qw{ id name shortName phones postalCode address url vk links };
my @set = qw{ id links name phones postalCode url };

for my $p (@all) {
    ok $a->can($p), "can $p";
}

ok $a->can('properties'), "can properties";
is_deeply $a->properties->{all}, \@all, 'all properties';
is_deeply $a->properties->{string}, [ qw/id name shortName url address postalCode vk/ ], 'string properties';
is_deeply $a->properties->{array}, [ qw/phones links/ ];
is_deeply $a->properties->{set}, \@set, 'all set properties';

my $b = [
    12345,
    'Romashka LLC',
    undef,
    '+1-541-754-3010
+49-89-636-48018',
    344000,
    undef,
    'example.com',
    undef,
    'http://foo.bar'
];

is ref($a->to_array), 'ARRAY', 'Yandex::Geo::Company/to_array return array';

# check sequence of returned array by @all variable (taken from Object::Tiny definition of Yandex::Geo::Company)
is_deeply $a->to_array, $b, 'Yandex::Geo::Company/to_array works as documented';

done_testing;