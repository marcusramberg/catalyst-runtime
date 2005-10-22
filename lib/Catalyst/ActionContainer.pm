package Catalyst::ActionContainer;

use strict;
use base qw/Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/part actions/);

use overload (

    # Stringify to path part for tree search
    q{""} => sub { shift->{part} },

);

=head1 NAME

Catalyst::Action - Catalyst Action

=head1 SYNOPSIS

See L<Catalyst>.

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item part

=item actions

=item new

=cut

sub new {        # Dumbass constructor
    my ( $class, $attrs ) = @_;
    return bless { %{ $attrs || {} } }, $class;
}

=back

=head1 AUTHOR

Matt S. Trout

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
