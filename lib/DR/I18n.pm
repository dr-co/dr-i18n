package DR::I18n;
use Mouse;
use utf8;
use base qw(Exporter);
use feature qw(state);

our $VERSION = '0.11';
our @EXPORT = our @EXPORT_OK = qw(__ po);

use Carp;
use Locale::PO;
use Locales;

use File::Spec::Functions   qw(catfile);
use File::Basename          qw(basename);
use Data::Dumper;

# Froce base directory
our $BASEDIR;

=encoding utf-8

=head1 NAME

DR::I18n - Simple internatialization

=head1 SYNOPSIS

    use DR::I18n;

=head1 DESCRIPTION

=head1 METHODS

=cut

sub po {
    state $po;
    $po //= __PACKAGE__->new( dir => $BASEDIR );
    return $po;
}

sub __($) { return po->gettext( @_ ) }

has origin          => is => 'rw', isa => 'Str',        default => 'ru';
has langs           => is => 'rw', isa => 'ArrayRef',   default => sub{[]};
has dict            => is => 'ro', isa => 'HashRef',
                       lazy => 1, builder => '_build_dict';
has dir             => is => 'ro', isa => 'Str',        default => 'po';

has available       => is => 'ro', isa => 'HashRef',
                       lazy => 1, builder => '_build_available';

sub gettext {
    my ($self, $msg) = @_;


    my $idutf = Locale::PO->quote( $msg );
    my $id = $idutf;
    utf8::encode $id if utf8::is_utf8 $id;


    for my $lang ( @{$self->langs}, $self->origin ) {

        if( $lang eq $self->origin ) {
            last unless exists $self->dict->{ $lang };

            my $d;

            if (exists $self->dict->{ $lang }{ $id }) {
                $d = $self->dict->{ $lang }{ $id };
            } elsif (exists $self->dict->{ $lang }{ $idutf }) {
                $d = $self->dict->{ $lang }{ $idutf };
            } else {
                last;
            }

            my $str = $d->dequote( $d->msgstr );
            utf8::decode $str unless utf8::is_utf8 $str;
            last unless defined $str;
            last unless length $str;
            return $str;
        }

        # Пропустим отсутствующий язык
        next unless exists $self->dict->{ $lang };

        my $d;
        if (exists $self->dict->{ $lang }{ $id }) {
            $d = $self->dict->{ $lang }{ $id };
        } elsif (exists $self->dict->{ $lang }{ $idutf }) {
            $d = $self->dict->{ $lang }{ $idutf };
        } else {
            next;
        }
        # Попустим строку с неточным переводом
        next if $d->fuzzy;

        # Получим перевод
        my $str = $d->dequote( $d->msgstr );
        utf8::decode $str unless utf8::is_utf8 $str;

        # Пропустим если перевода нет
        next unless defined $str;
        next unless length $str;
        # Пропустим если перевода нет, а была простая копипаста
        next if $str eq  $msg;

        return $str;
    }

    return $msg;
}

sub _build_dict {
    my ($self) = @_;

    croak 'Directory not found' unless -d $self->dir;

    my @files = glob catfile $self->dir, '*.po';
    my @langs = map { basename $_, '.po' } @files;

    my %po;
    for my $file ( @files ) {
        my $lang = basename $file, '.po';

        $po{ $lang } = Locale::PO->load_file_ashash( $file => 'UTF-8' );
    }

    return \%po;
}

sub _build_available {
    my ($self) = @_;


    my %list;
    for my $code ( keys %{ $self->dict } ) {
        $list{ $code }{code} = $code;

        my $locale = Locales->new( $code );
        $list{ $code }{language} =
            $locale->get_native_language_from_code( $code );
        utf8::decode $list{ $code }{language}
            unless utf8::is_utf8 $list{ $code }{language};
    }
    return \%list;
}

sub import {
    my ($package, @args) = @_;

    for (0 .. $#args - 1) {
        if ($args[$_] and $args[$_] eq 'dir') {
            (undef, $BASEDIR) = splice @args, $_, 2;
            redo;
        }
    }

    $package->export_to_level(1, $package, @args);
}

__PACKAGE__->meta->make_immutable();
1;
