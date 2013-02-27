use utf8;
use strict;
use warnings;

package Mojolicious::Plugin::DR::I18n;
use Mojo::Base 'Mojolicious::Plugin';

use Carp;
use File::Spec::Functions 'catfile';
use DR::I18n dir => catfile $ENV{MOJO_HOME} || '.', 'po';

my $VERSION = '0.1';


sub register {
    my ($self, $app, $conf) = @_;

    # Configuration
    $conf               ||= {};

    $app->helper( __ => sub{ return __ $_[1] } );

    $app->hook(before_dispatch => sub {
        my $c = shift;
        my @langs = split m{\s*,\s*}, $c->req->headers->accept_language;
        my %exists;
        for my $index ( reverse 0 .. $#langs ) {
            $langs[$index] =~ s{\s*;.*}{};

            $exists{ $langs[$index] } = 1;
            if( $langs[$index] =~ m{(.*?)[-_]} ) {
                splice @langs, $index, 1, $langs[$index], $1 unless $exists{$1};
            }
        }

        po->langs( \@langs );
    });
}

1;

=head1 COPYRIGHT

 Copyright (C) 2011 Dmitry E. Oboukhov <unera@debian.org>
 Copyright (C) 2011 Roman V. Nikolaev <rshadow@rambler.ru>

 All rights reserved. If You want to use the code You
 MUST have permissions from Dmitry E. Oboukhov AND
 Roman V Nikolaev.

=cut

