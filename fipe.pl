package  WWW::Tabela::Fipe::Parser;
use Moo;

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
use CHI;
use HTTP::Tiny;
use HTTP::CookieJar;

my $robot = HTML::Robot::Scrapper->new (
    reader    => {                                                       # REQ
        class => 'WWW::Tabela::Fipe',
    },
    writer    => {class => 'WWW::Tabela::FipeWrite',}, #REQ
    benchmark => {class => 'Default'},
#   cache     => {
#       class => 'Default',
#       args  => {
#           is_active => 0,
#           engine => CHI->new(
#                   driver => 'BerkeleyDB',
#                   root_dir => "/home/catalyst/WWW-Tabela-Fipe/cache/",
#           ),
#       },
#   },
    log       => {class => 'Default'},
    parser    => {class => 'WWW::Tabela::Fipe::Parser'},  #custom para tb fipe. pois eles respondem com Content type text/plain
    queue     => {class => 'Default'},
    useragent => {
        class => 'Default',
        args  => {
            ua => HTTP::Tiny->new( cookie_jar => HTTP::CookieJar->new),
        }
    },
    encoding  => {class => 'Default'},
    instance  => {class => 'Default'},
);

$robot->start();
