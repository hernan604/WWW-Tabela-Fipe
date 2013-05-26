package WWW::Tabela::FipeWrite;
use Text::CSV;
use Moo;

sub write {
    my ( $self, $item ) = @_; 
    my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                    or die "Cannot use CSV: ".Text::CSV->error_diag ();
    open my $fh, ">>:encoding(utf8)", "fipe.csv" or die "fipe.csv: $!";
    my @atributos = map { $item->{ $_ } } keys %$item;
    $csv->print ($fh, \@atributos ) ;
    print $fh "\n";
    close $fh;
}


1;
