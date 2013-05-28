# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More;

BEGIN { 
    use_ok( 'HTML::Robot::Scrapper' );
    use_ok( 'WWW::Tabela::Fipe' );
}


done_testing();

