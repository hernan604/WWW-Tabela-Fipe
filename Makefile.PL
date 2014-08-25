

use ExtUtils::MakeMaker;

my $mm_ver = $ExtUtils::MakeMaker::VERSION;
if ($mm_ver =~ /_/) { # dev version
    $mm_ver = eval $mm_ver;
    die $@ if $@;
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'WWW::Tabela::Fipe',
    VERSION_FROM => 'lib/WWW/Tabela/Fipe.pm', # finds \$VERSION
    AUTHOR       => 'HERNAN (hernan@cpan.org)',
    ABSTRACT     => 'Baixe a tabela fipe completa mantenha-se atualizado',
    PREREQ_PM    => {
                     'Test::Simple'             => 0.44,
                     'Moo'                      => 0,
                     'HTML::Entities'           => 0,
                     'HTTP::Request::Common'    => 0,
                     'HTML::Robot::Scrapper'    => 0,
                     'Data::Printer'            => 0,
                     'File::Slurp::Tiny'        => 0,
                     'HTTP::CookieJar'          => 0,
                     'JSON::XS'                 => 0,
                    },
    ($mm_ver >= 6.31
        ? (LICENSE => 'perl')
        : ()),

    ($mm_ver <= 6.45
        ? ()
        : (META_MERGE => {
            'meta-spec' => { version => 2 },
            resources => {
                bugtracker  => 'http://rt.cpan.org/Public/Dist/Display.html?Name=WWW-Tabela-Fipe',
                repository  => {
                    type => 'git',
                    web  => 'https://github.com/hernan604/WWW-Tabela-Fipe',
                    url  => 'git://github.com/hernan604/WWW-Tabela-Fipe.git',
                },
            },
          })

    ),

);
