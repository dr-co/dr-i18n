#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 13;

BEGIN {
    use_ok 'DR::I18n', 'dir' => 't/po';
}

my $po = DR::I18n->new( dir => 't/po', origin => 'ru' );
ok $po, 'Object created';

note 'Translations';
{
    ok $po->langs(['en']), 'Set en language';
    is $po->gettext('Одна строка %s'), 'Some string %s', 'Complete';
    is $po->gettext('Другая строка'),  'Another string', 'Complete';

    ok $po->langs(['ru']), 'Set ru language';
    is $po->gettext('Одна строка %s'), 'Одна строка %s', 'Complete';
    is $po->gettext('Другая строка'),  'Другая строка',  'Complete';
}

note 'Available list';
{
    my $a = $po->available;
    isa_ok $a, 'HASH', 'Available hash';
    is scalar keys %$a, 2, 'Two languages';
}

note 'Exports';
{
    isa_ok po, 'DR::I18n';
    ok po->langs(['en']), 'Set en language';

    is __ 'Одна строка %s', 'Some string %s', '__"..."';
}


=head1 COPYRIGHT

Copyright (C) 2011 Dmitry E. Oboukhov <unera@debian.org>
Copyright (C) 2011 Roman V. Nikolaev <rshadow@rambler.ru>

All rights reserved. If You want to use the code You
MUST have permissions from Dmitry E. Oboukhov AND
Roman V Nikolaev.

=cut
