package TestApp;

use Catalyst qw[-Engine=Test];

sub foo : Global {
    my ( $self, $c ) = @_;
    $c->res->output( $c->req->params->{foo} );
}

__PACKAGE__->setup;

package main;

use Test::More tests => 1;
use Catalyst::Test 'TestApp';

ok( get('/foo?foo=bar') =~ /bar/ );
