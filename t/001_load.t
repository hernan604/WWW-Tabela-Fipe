# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'WWW::Tabela::Fipe' ); }

my $object = WWW::Tabela::Fipe->new ();
isa_ok ($object, 'WWW::Tabela::Fipe');


