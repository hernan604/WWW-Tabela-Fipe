package WWW::Tabela::Fipe;
use Moo;
with 'HTML::Robot::Scrapper::Reader';
use Data::Printer;
use utf8;
use HTML::Entities;
use HTTP::Request::Common qw(POST);

has [ qw/marcas viewstate eventvalidation/ ] => ( is => 'rw' );

has veiculos => ( is => 'rw' , default => sub { return []; });
has referer => ( is => 'rw' );

sub start {
    my ( $self ) = @_;
}

has startpage => (
    is      => 'rw',
    default => sub {
        return [
          { 
            tipo => 'moto',
            url  => 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?azxp=1&v=m&p=52' 
          },
          { 
            tipo => 'carro', 
            url  => 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?p=51' 
          },
          { 
            tipo => 'caminhao',
            url  => 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?v=c&p=53' 
          },
        ] 
    },
);

sub on_start {
  my ( $self ) = @_;
  foreach my $item ( @{ $self->startpage } ) {
    $self->append( search => $item->{ url }, {
        passed_key_values => {
            tipo    => $item->{ tipo },
            referer => $item->{ url },
        }
    } );
  }
}

sub _headers {
    my ( $self , $url, $form ) = @_; 
    return {
      'Accept'          => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate',
      'Accept-Language' => 'en-US,en;q=0.5',
      'Cache-Control'   => 'no-cache',
      'Connection'      => 'keep-alive',
      'Content-Length'  => length( POST('url...', [], Content => $form)->content ),
      'Content-Type'    => 'application/x-www-form-urlencoded; charset=utf-8',
      'DNT'             => '1',
      'Host'            => 'www.fipe.org.br',
      'Pragma'          => 'no-cache',
      'Referer'         => $url,
      'User-Agent'      => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:20.0) Gecko/20100101 Firefox/20.0',
      'X-MicrosoftAjax' => 'Delta=true',
    };
}

sub _form {
    my ( $self, $args ) = @_; 
    return [
      ScriptManager1      => $args->{ script_manager },
      __ASYNCPOST         => 'true',
      __EVENTARGUMENT     => '',
      __EVENTTARGET       => $args->{ event_target },
      __EVENTVALIDATION   => $args->{ event_validation },
      __LASTFOCUS         => '',
      __VIEWSTATE         => $args->{ viewstate },
      ddlAnoValor         => ( !exists $args->{ano} ) ? 0 : $args->{ ano },
      ddlMarca            => ( !exists $args->{marca} ) ? 0 : $args->{ marca },
      ddlModelo           => ( !exists $args->{modelo} ) ? 0 : $args->{ modelo },
      ddlTabelaReferencia => 154,
      txtCodFipe          => '',
    ];
}

sub search {
  my ( $self ) = @_;
  my $marcas           = $self->tree->findnodes( '//select[@name="ddlMarca"]/option' );
  my $viewstate        = $self->tree->findnodes( '//form[@id="form1"]//input[@id="__VIEWSTATE"]' )->get_node->attr('value');
  my $event_validation = $self->tree->findnodes( '//form[@id="form1"]//input[@id="__EVENTVALIDATION"]' )->get_node->attr('value');
  foreach my $marca ( $marcas->get_nodelist ) {
    my $form = $self->_form( {
        script_manager => 'UdtMarca|ddlMarca',
        event_target   => 'ddlMarca',
        event_validation=> $event_validation,
        viewstate       => $viewstate,
        marca           => $marca->attr( 'value' ),
    } );
    $self->prepend( busca_marca => 'url' , {
      passed_key_values => {
          marca     => $marca->as_text,
          marca_id  => $marca->attr( 'value' ),
          tipo      => $self->robot->reader->passed_key_values->{ tipo },
          referer   => $self->robot->reader->passed_key_values->{referer },
      },
      request => [
        'POST',
        $self->robot->reader->passed_key_values->{ referer },
        {
          headers => $self->_headers( $self->robot->reader->passed_key_values->{ referer } , $form ),
          content => POST('url...', [], Content => $form)->content,
        }
      ]
    } );        
  }
}

sub busca_marca {
  my ( $self ) = @_; 
  my ( $captura1, $viewstate )         = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.+)__VIEWSTATE\|([^\|]+)\|/g;
  my ( $captura_1, $event_validation ) = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.+)__EVENTVALIDATION\|([^\|]+)\|/g;
  my $modelos = $self->tree->findnodes( '//select[@name="ddlModelo"]/option' );
  foreach my $modelo ( $modelos->get_nodelist ) {


    next unless $modelo->as_text !~ m/selecione/ig;
    my $kv={};
    $kv->{ modelo_id }  = $modelo->attr( 'value' );
    $kv->{ modelo }     = $modelo->as_text;
    $kv->{ marca_id }   = $self->robot->reader->passed_key_values->{ marca_id };
    $kv->{ marca }      = $self->robot->reader->passed_key_values->{ marca };
    $kv->{ tipo }       = $self->robot->reader->passed_key_values->{ tipo };
    $kv->{ referer }    = $self->robot->reader->passed_key_values->{ referer };
    my $form = $self->_form( {
        script_manager => 'updModelo|ddlModelo',
        event_target   =>  'ddlModelo',
        event_validation=> $event_validation,
        viewstate       => $viewstate,
        marca           => $kv->{ marca_id },
        modelo          => $kv->{ modelo_id },
    } );
    $self->prepend( busca_modelo => '', {
      passed_key_values => $kv,
      request => [
        'POST',
        $self->robot->reader->passed_key_values->{ referer },
        {
          headers => $self->_headers( $self->robot->reader->passed_key_values->{ referer } , $form ),
          content => POST( 'url...', [], Content => $form )->content,
        }
      ]
    } );    
  }
}

sub busca_modelo {
  my ( $self ) = @_; 
  my $anos = $self->tree->findnodes( '//select[@name="ddlAnoValor"]/option' );
  foreach my $ano ( $anos->get_nodelist ) {
    my $kv = {};
    $kv->{ ano_id }     = $ano->attr( 'value' );
    $kv->{ ano }        = $ano->as_text;
    $kv->{ modelo_id }  = $self->robot->reader->passed_key_values->{ modelo_id };
    $kv->{ modelo }     = $self->robot->reader->passed_key_values->{ modelo };
    $kv->{ marca_id }   = $self->robot->reader->passed_key_values->{ marca_id };
    $kv->{ marca }      = $self->robot->reader->passed_key_values->{ marca };
    $kv->{ tipo }       = $self->robot->reader->passed_key_values->{ tipo };
    $kv->{ referer }    = $self->robot->reader->passed_key_values->{ referer };
    next unless $ano->as_text !~ m/selecione/ig;

    my ( $captura1, $viewstate )         = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.*)__VIEWSTATE\|([^\|]+)\|/g;
    my ( $captura_1, $event_validation ) = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.*)__EVENTVALIDATION\|([^\|]+)\|/g;
    my $form = $self->_form( {
        script_manager => 'updAnoValor|ddlAnoValor',
        event_target   =>  'ddlAnoValor',
        event_validation=> $event_validation,
        viewstate       => $viewstate,
        marca           => $kv->{ marca_id },
        modelo          => $kv->{ modelo_id },
        ano             => $kv->{ ano_id },
    } );

    $self->prepend( busca_ano => '', {
      passed_key_values => $kv,
      request => [
        'POST',
        $self->robot->reader->passed_key_values->{ referer },
        {
          headers => $self->_headers( $self->robot->reader->passed_key_values->{ referer } , $form ),
          content => POST( 'url...', [], Content => $form )->content,
        }
      ]
    } );    
  }
}

sub busca_ano {
  my ( $self ) = @_; 
  my $item = {};
  $item->{ mes_referencia }   = $self->tree->findvalue('//span[@id="lblReferencia"]') ;
  $item->{ cod_fipe }         = $self->tree->findvalue('//span[@id="lblCodFipe"]');
  $item->{ marca }            = $self->tree->findvalue('//span[@id="lblMarca"]');
  $item->{ modelo }           = $self->tree->findvalue('//span[@id="lblModelo"]');
  $item->{ ano }              = $self->tree->findvalue('//span[@id="lblAnoModelo"]');
  $item->{ preco }            = $self->tree->findvalue('//span[@id="lblValor"]');
  $item->{ data }             = $self->tree->findvalue('//span[@id="lblData"]');
  $item->{ tipo }             = $self->robot->reader->passed_key_values->{ tipo } ;
  warn p $item;

  push( @{$self->veiculos}, $item );
}

sub on_link {
    my ( $self, $url ) = @_;
}

sub on_finish {
    my ( $self ) = @_; 
    warn "Terminou.... exportando dados.........";
    $self->robot->writer->write( $self->veiculos );
}

=head1 NAME

WWW::Tabela::Fipe - Baixe a tabela fipe completa mantenha-se atualizado

=head1 SYNOPSIS

  use WWW::Tabela::Fipe;
  blah blah blah


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE



=head1 BUGS



=head1 SUPPORT



=head1 AUTHOR

    HERNAN
    CPAN ID: HERNAN
    perldelux
    hernan@cpan.org
    http://github.com/hernan604

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

