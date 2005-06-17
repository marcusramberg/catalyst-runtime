package Catalyst::Base;

use strict;
use base qw/Class::Data::Inheritable Class::Accessor::Fast/;
use Catalyst::Utils;
use Catalyst::Exception;
use NEXT;

# Some caches...
__PACKAGE__->mk_classdata($_) for qw/_attr_cache _action_cache _config/;
__PACKAGE__->_attr_cache( {} );
__PACKAGE__->_action_cache( [] );

# note - see attributes(3pm)
sub MODIFY_CODE_ATTRIBUTES {
    my ( $class, $code, @attrs ) = @_;
    $class->_attr_cache->{$code} = [@attrs];
    push @{ $class->_action_cache }, [ $code, [@attrs] ];
    return ();
}

sub FETCH_CODE_ATTRIBUTES { $_[0]->_attr_cache->{ $_[1] } || () }

=head1 NAME

Catalyst::Base - Catalyst Universal Base Class

=head1 SYNOPSIS

    # lib/MyApp/Model/Something.pm
    package MyApp::Model::Something;

    use base 'Catalyst::Base';

    __PACKAGE__->config( foo => 'bar' );

    sub test {
        my $self = shift;
        return $self->{foo};
    }

    sub forward_to_me {
        my ( $self, $c ) = @_;
        $c->response->output( $self->{foo} );
    }
    
    1;

    # Methods can be a request step
    $c->forward(qw/MyApp::Model::Something forward_to_me/);

    # Or just methods
    print $c->comp('MyApp::Model::Something')->test;

    print $c->comp('MyApp::Model::Something')->{foo};

=head1 DESCRIPTION

This is the universal base class for Catalyst components
(Model/View/Controller).

It provides you with a generic new() for instantiation through Catalyst's
component loader with config() support and a process() method placeholder.

=head1 METHODS

=over 4

=item new($c)

=cut

sub new {
    my ( $self, $c ) = @_;

    # You'll find yourself naked and strung from a tree if you ever
    # remove this again, k? :)
    my $class     = ref $self || $self;
    my $appname   = Catalyst::Utils::class2appclass($class);
    my $suffix    = Catalyst::Utils::class2classsuffix($class);
    my $appconfig = {};

    # Not catched, for compatibility with non Catalyst apps
    eval '$appconfig = $appname->config->{$suffix} || {}';
    my $config = { %{ $self->config }, %{$appconfig} };

    # Temporary fix, some components does not pass context to constructor
    my $arguments = ( ref( $_[-1] ) eq 'HASH' ) ? $_[-1] : {};

    return $self->NEXT::new( { %{$config}, %{$arguments} } );
}

# remember to leave blank lines between the consecutive =item's
# otherwise the pod tools don't recognize the subsequent =items

=item $c->config

=item $c->config($hashref)

=item $c->config($key, $value, ...)

=cut

sub config {
    my $self = shift;
    $self->_config( {} ) unless $self->_config;
    if (@_) {
        my $config = @_ > 1 ? {@_} : $_[0];
        while ( my ( $key, $val ) = each %$config ) {
            $self->_config->{$key} = $val;
        }
    }
    return $self->_config;
}

=item $c->process()

=cut

sub process {

    Catalyst::Exception->throw( message => ( ref $_[0] || $_[0] )
          . " did not override Catalyst::Base::process" );
}

=item FETCH_CODE_ATTRIBUTES

=item MODIFY_CODE_ATTRIBUTES

=back

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>
Marcus Ramberg, C<mramberg@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
