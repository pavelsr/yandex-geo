# ABSTRACT: Convenient representation of company from Yandex Maps

package Yandex::Geo::Company;

use strict;
use warnings;

=head1 NAME

Yandex::Geo::Company

=head1 SYNOPSYS

    use Yandex::Geo::Company;
    my $a = Yandex::Geo::Company->new ( name => 'Test LLC' );
    warn $a->name;   # 'Test LLC'
    warn $a->foo;    # Can't locate object method "foo" via package "Yandex::Geo::Company"
    
    Yandex::Geo::Company::from_json( $res->to_json )
    Yandex::Geo::Company::from_geo_json( $res )

=head1 DESCRIPTION

Class that is more convenient realization of company

It has following properties:
    
    id          # yandex maps id
    name        # name of company, type = string
    shortName   # short name of company, type = string
    url         # website of company, type = string
    phones      # company numbers, type = arrayref
    links       # links to pages on social networks, type = arrayref
    vk          # link to vk, type = string
    address     # location, type = str
    postalCode  # postal code, type = str (6 digits)
    
Also, this class implements two methods: from_json and from_geo_json

If you make a query

    my $yndx_geo = Yandex::Geosearch->new( apikey => 'f33a4523-6c94-48df-9b41-5c5c6f250e98');
    my $res = $yndx_geo->get(text => 'макетные мастерские', only_city => 'ROV');

and process C<$res>

    Yandex::Geo::Company->from_json( $res->to_json )
    
and
    
    Yandex::Geo::Company->from_geo_json( $res )
    
do the same.

=cut

use Class::Tiny qw{ id name shortName phones postalCode address url vk instagram links longitude latitude };
use JSON::XS;

=head2 properties

    Yandex::Geo::Company::properties();

Detailed info about L<Yandex::Geo::Company> properties

Return hashref with following keys:

    set     - list if all set properties names, regardless of type, in alphabetic order
    all     - list if all available properties names, regardless of type, in alphabetic order
    string  - list of all properties names with type = string
    array   - list of all properties names with type = ARRAY

=cut

sub properties {
    # my $self = shift;
    return {
        # set => [ sort keys $self ],
        all => [ qw{ id name shortName phones postalCode address url vk instagram links longitude latitude } ],
        string => [ qw/id name shortName url address postalCode vk instagram longitude latitude/ ],
        array => [ qw/phones links/ ]   # real properties in capital case
    };
}

=head2 from_geo_json

Accept L<Geo::JSON::FeatureCollection>  as C<$json> and return array of L<Yandex::Geo::Company> objects

    Yandex::Geo::Company::from_geo_json($json);

=cut

sub from_geo_json {
    my $feature_collection = shift;
    
    my @result;
    
    for my $f ( @{$feature_collection->features} ) {
        
        my $company_meta = $f->properties->{CompanyMetaData};
        
        my $h = {};
        
        for ( @{ __PACKAGE__->properties->{string} } ) { 
            $h->{$_} = $company_meta->{$_} 
        };
        
        push @{$h->{phones}}, $_->{formatted} for ( @{ $company_meta->{Phones} } );
        push @{$h->{links}}, $_->{href} for ( @{ $company_meta->{Links} } );
        
        my $vk_link = ( grep { $_->{aref} eq '#vkontakte' } @{ $company_meta->{Links} } )[0];
        $h->{vk} = $vk_link->{href} if defined $vk_link;
        
        my $inst_link = ( grep { $_->{aref} eq '#instagram' } @{ $company_meta->{Links} } )[0];
        $h->{instagram} = $inst_link->{href} if defined $inst_link;
        
        $h->{longitude} = $f->geometry->coordinates->[1];
        $h->{latitude} = $f->geometry->coordinates->[0];
    
        my $company_obj = __PACKAGE__->new(%$h);
        
        push @result, $company_obj;
        
    }
    
    return \@result;
    
}

=head2 from_json

Parse regular json to arrayref of L<Yandex::Geo::Company> objects

    Yandex::Geo::Company::from_json($json);

=cut

sub from_json {
    my $json_str = shift;
    
    my $res = decode_json $json_str;
    my $features = @{$res->{features}};
    
    my @result;
    
    for my $f (@$features) {
        
        my $company_meta = $f->{properties}{CompanyMetaData};
        my $h = {};
        
        for ( @{ __PACKAGE__->properties->{string} } ) { 
            $h->{$_} = $company_meta->{$_} 
        };
        
        push @{$h->{phones}}, $_->{formatted} for ( @{ $company_meta->{Phones} } );
        push @{$h->{links}}, $_->{href} for ( @{ $company_meta->{Links} } );
        my $vk_link = ( grep { $_->{aref} eq '#vkontakte' } @{ $company_meta->{Links} } )[0];
        $h->{vk} = $vk_link->{href} if defined $vk_link;
        
        my $company_obj = __PACKAGE__->new(%$h);
        
        push @result, $company_obj;
    }
    
    return \@result;

}

=head2 to_array

    $y_company->to_array;  # $y_company is L<Yandex::Geo::Company> object
    $y_company->to_array("\n");

Serialize object data to arrayref.

Can be useful when inserting data via modules like L<Text::CSV>

Sequence is according to L<Yandex::Geo::Company/properties> C<{all}>

Array properties like C<phones, links> are serialized, each element on new string

=cut

sub to_array {
    my ($self, $separator) = @_;
    
    $separator = "\n" unless defined $separator;
    my @res;
    
    for my $p ( @{ properties()->{all} }) {
        
        if ( ref($self->$p) eq 'ARRAY' ) {
            $self->$p( join( $separator, @{$self->$p} ));
        }
        
        push @res, $self->$p;
        
    }
    
    return \@res;
}

1;
