package  WWW::Tabela::Fipe::Parser;
use Moo;

has [qw/engine robot/] => ( is => 'rw' );

with('HTML::Robot::Scrapper::Parser::HTML::TreeBuilder::XPath'); 
with('HTML::Robot::Scrapper::Parser::XML::XPath'); 

sub content_types {
    my ( $self ) = @_;
    return {
        'text/html' => [
            {
                parse_method => 'parse_xpath',
                description => q{
                    The method above 'parse_xpath' is inside class:
                    HTML::Robot::Scrapper::Parser::HTML::TreeBuilder::XPath
                },
            }
        ],
        'text/plain' => [
            {
                parse_method => 'parse_xpath',
                description => q{
                    esse site da fipe responde em text/plain e eu preciso parsear esse content type.
                    por isso criei esta classe e passei ela como parametro, sobreescrevendo a classe 
                    HTML::Robot::Scrapper::Parser::Default
                },
            }
        ],
        'text/xml' => [
            {
                parse_method => 'parse_xml'
            },
        ],
    };
}

1;

package FIPE;

use HTML::Robot::Scrapper;
#use CHI;
use HTTP::Tiny;
use HTTP::CookieJar;
use WWW::Tabela::Fipe;
use WWW::Tabela::FipeWrite;
#use WWW::Tabela::Fipe::Parser;
use HTML::Robot::Scrapper::UserAgent::Default;

my $robot = HTML::Robot::Scrapper->new(
    reader    => WWW::Tabela::Fipe->new,
    writer    => WWW::Tabela::FipeWrite->new,
#   cache     => 
#           CHI->new(
#                   driver => 'BerkeleyDB',
#                   root_dir => "/home/catalyst/WWW-Tabela-Fipe/cache/",
#           ),
    parser    => WWW::Tabela::Fipe::Parser->new,  #custom para tb fipe. pois eles respondem com Content type text/plain
    useragent => HTML::Robot::Scrapper::UserAgent::Default->new(
                 ua => HTTP::Tiny->new( 
                    cookie_jar => HTTP::CookieJar->new,
                    agent      => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/24.0'
                 ),

    )
);

$robot->start();
