#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib ../../lib);

use Test::More tests => 18;
use Encode qw(decode encode);


BEGIN {
    use_ok 'Test::Mojo';
    $ENV{MOJO_HOME} = 't';
    require_ok 'DR::I18n';
}

{
    package MyApp;
    use Mojo::Base 'Mojolicious';

    sub startup {
        my ($self) = @_;
        $self->plugin('DR::I18n');
    }
    1;
}

my $t = Test::Mojo->new('MyApp');
ok $t, 'Test Mojo created';

note 'Hook';
{
    $t->app->routes->post("/")->to( cb => sub {
        my ($self) = @_;

        is_deeply DR::I18n::po->langs, ['ru-RU','ru','en-US','en'],
            'Language parsed';

        $self->render(text => 'OK.');
    });

    $t->post_ok("/" => {
        'Accept-Language' => 'ru-RU,en-US;q=0.6,en;q=0.4'
    })-> status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'Translations';
{
    $t->app->routes->post("/index")->to('my_app#index');

    $t->post_ok("/index" => {
        'Accept-Language' => 'en-US;q=0.6,en;q=0.4'
    })  ->status_is( 200 )
        ->content_like(qr{Some string %s});

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'List of aviable languages';
{
    $t->app->routes->post("/langs")->to( cb => sub {
        my ($self) = @_;

        is scalar @{$self->langs_available}, 2, 'List';

        $self->render(text => 'OK.');
    });

    $t->post_ok("/langs" => {
        'Accept-Language' => 'en-US;q=0.6,en;q=0.4'
    })  ->status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

note 'Cookie force';
{
    $t->app->routes->get("/set_lang")->to(cb => sub {
        my ($self) = @_;
        $self->session(lang => 'tr');
        $self->render(text => 'OK.');
    });
    $t->app->routes->post("/force")->to(cb => sub {
        my ($self) = @_;

        is $self->session('lang'), 'tr', 'Saved tr';
        is $self->langs_priority->[0], 'tr', 'Forced tr';

        $self->render(text => 'OK.');
    });

    # Get cookie
    $t->get_ok("/set_lang")->status_is( 200 );
    # Send forced
    $t->post_ok("/force" => {
        'Accept-Language' => 'en-US;q=0.6,en;q=0.4',
    })  ->status_is( 200 );

    diag decode utf8 => $t->tx->res->body unless $t->tx->success;
}

=head1 COPYRIGHT

Copyright (C) 2011 Dmitry E. Oboukhov <unera@debian.org>

Copyright (C) 2011 Roman V. Nikolaev <rshadow@rambler.ru>

All rights reserved. If You want to use the code You
MUST have permissions from Dmitry E. Oboukhov AND
Roman V Nikolaev.

=cut

__DATA__
@@my_app/index.html.ep

%= __('Одна строка %s')

