use utf8;
use strict;
use warnings;

package Mojolicious::Plugin::DR::I18n;
use Mojo::Base 'Mojolicious::Plugin';

use Carp;
use File::Spec::Functions   qw(rel2abs catdir);

use DR::I18n dir => rel2abs catdir $ENV{MOJO_HOME} || '.', 'po';

my $VERSION = '0.10';


sub register {
    my ($self, $app, $conf) = @_;

    # Configuration
    $conf               ||= {};

    $app->helper( __ => sub {
        my ($self, $fmt, @args) = @_;
        return undef unless defined $fmt;
        return sprintf(__($fmt), @args) if @args;
        return __ $fmt;
    });

    $app->helper( langs_available => sub{
        return [
            sort {$a->{code} cmp $b->{code}}
            values %{ po->available }
        ];
    });

    $app->helper( langs_priority => sub{ return po->langs });

    $app->hook(before_dispatch => sub {
        my $c = shift;

        my @langs = split m{\s*,\s*}, $c->req->headers->accept_language // '';
        my %exists;

        # Make list of accepted langusges
        for my $index ( reverse 0 .. $#langs ) {
            $langs[$index] =~ s{\s*;.*}{};
            $langs[$index] = substr $langs[$index], 0, 10;

            $exists{ $langs[$index] } = 1;
            if( $langs[$index] =~ m{(.*?)[-_]} ) {
                splice @langs, $index, 1, $langs[$index], $1 unless $exists{$1};
            }
        }

        # Force language from session
        if( $c->session('lang') ) {
            my $force = substr $c->session('lang'), 0, 10;
            unshift @langs, $force;
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

