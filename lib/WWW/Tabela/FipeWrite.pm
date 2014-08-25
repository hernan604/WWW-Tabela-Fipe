package WWW::Tabela::FipeWrite;
use JSON::XS;
use File::Slurp::Tiny qw( write_file );
use Moo;

sub write {
    my ( $self, $veiculos ) = @_; 
    write_file( 'fipe.json', encode_json $veiculos );
}


1;
