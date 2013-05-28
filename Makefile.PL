

use ExtUtils::MakeMaker;
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
                     'File::Slurp'              => 0,
                     'HTTP::CookieJar'          => 0,
                     'JSON::XS'                 => 0,
                    },
);
