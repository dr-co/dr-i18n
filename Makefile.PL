use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => "DR::I18n",
    VERSION_FROM    => "lib/DR/I18n.pm",
    ABSTRACT_FROM   => "lib/DR/I18n.pm",
    MAKEFILE        => 'Makefile',
    LICENSE         => 'Perl',
    AUTHOR          => [
        'Dmitry E. Oboukhov <unera@debian.org>,',
        'Roman V. Nikolaev <rshadow@rambler.ru>',
    ],
    MIN_PERL_VERSION => '5.10.0',
    PREREQ_PM       => {
        'Locale::PO'                    => '0',
        'Locales'                       => '0',
        'Test::Compile'                 => '0',
        'Test::More'                    => '0',
        'Test::Debian'                  => '0',
    },
    META_MERGE => {
        resources => {
            homepage =>
                'https://github.com/dr-co/dr-i18n',
            bugtracker =>
                'https://github.com/dr-co/dr-i18n/issues',
        }
   }
);
