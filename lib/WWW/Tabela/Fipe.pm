package WWW::Tabela::Fipe;
use Moo;
with 'HTML::Robot::Scrapper::Reader';
use Data::Printer;
use utf8;
use HTML::Entities;
use HTTP::Request::Common qw(POST);

has [ qw/marcas viewstate eventvalidation/ ] => ( is => 'rw' );

sub start {
    my ( $self ) = @_;
}

has startpage => (
    is      => 'rw',
    default => sub { return 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?azxp=1&v=m&p=52' },
);

sub on_start {
  my ( $self ) = @_;
  $self->append( search => $self->startpage );
}

sub search {
  my ( $self ) = @_;
  warn $self->robot->useragent->content_type;
  my $marcas = $self->tree->findnodes( '//select[@name="ddlMarca"]/option' );
  my $event_stuff = {};
  $event_stuff->{ __VIEWSTATE }       = $self->tree->findnodes( '//form[@id="form1"]//input[@id="__VIEWSTATE"]' )->get_node->attr('value');
  $event_stuff->{ __EVENTVALIDATION } = $self->tree->findnodes( '//form[@id="form1"]//input[@id="__EVENTVALIDATION"]' )->get_node->attr('value');
  foreach my $marca ( $marcas->get_nodelist ) {
    warn $marca->attr( 'value' );
    warn $marca->as_text;
    my $form = [
      ScriptManager1      => 'UdtMarca|ddlMarca',
      __ASYNCPOST         => 'true',
      __EVENTARGUMENT     => '',
      __EVENTTARGET       => 'ddlMarca',
      __EVENTVALIDATION   => $event_stuff->{ __EVENTVALIDATION },
      __LASTFOCUS         => '',
      __VIEWSTATE         => $event_stuff->{ __VIEWSTATE },
      ddlAnoValor         => 0,
      ddlMarca            => $marca->attr( 'value' ),
      ddlModelo           => 0,
      ddlTabelaReferencia => 154,
      txtCodFipe          => '',
    ];
    $self->prepend( busca_marca => 'url' , {
      passed_key_values => {
          marca     => $marca->as_text,
          marca_id  => $marca->attr( 'value' ),
      },
      request => [
        'POST',
        'http://www.fipe.org.br/web/indices/veiculos/default.aspx?azxp=1&azxp=1%2c+1&v=m&p=52',
        {
          headers => {
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
            'Referer'         => 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?azxp=1&azxp=1%2C+1&v=m&p=52',
            'User-Agent'      => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:20.0) Gecko/20100101 Firefox/20.0',
            'X-MicrosoftAjax' => 'Delta=true',
          },
          content => POST('url...', [], Content => $form)->content,
        }
      ]
    } );        
  }
}

sub busca_marca {
  my ( $self ) = @_; 
# warn $self->robot->useragent->content_type;
  my ( $captura1, $viewstate )         = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.+)__VIEWSTATE\|([^\|]+)\|/g;
  my ( $captura_1, $event_validation ) = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.+)__EVENTVALIDATION\|([^\|]+)\|/g;
  $self->viewstate( $viewstate );
  $self->eventvalidation( $event_validation );
# warn p $self->robot->useragent->request_headers;
# warn p $self->robot->useragent->engine->ua;
  my $modelos = $self->tree->findnodes( '//select[@name="ddlModelo"]/option' );
  foreach my $modelo ( $modelos->get_nodelist ) {


    next unless $modelo->as_text !~ m/selecione/ig;
    my $kv={};
    $kv->{ modelo_id }  = $modelo->attr( 'value' );
    $kv->{ modelo }     = $modelo->as_text;
    $kv->{ marca_id }   = $self->robot->reader->passed_key_values->{ marca_id };
    $kv->{ marca }      = $self->robot->reader->passed_key_values->{ marca };
#   warn $self->robot->reader->passed_key_values->{ marca };
    my $form = [
      'ScriptManager1'      => 'updModelo|ddlModelo',
      '__ASYNCPOST'         => 'true',
      '__EVENTARGUMENT'     => '',
      '__EVENTTARGET'       => 'ddlModelo',
      '__EVENTVALIDATION'   => $self->eventvalidation,
      '__LASTFOCUS'         => '',
      '__VIEWSTATE'         => $self->viewstate,
      'ddlAnoValor'         => '0',
      'ddlMarca'            => $kv->{ marca_id },
      'ddlModelo'           => $kv->{ modelo_id },
      'ddlTabelaReferencia' => '154',
      'tctCodFipe'          => '',
    ];
    $self->prepend( busca_modelo => '', {
      passed_key_values => $kv,
      request => [
        'POST',
        'http://www.fipe.org.br/web/indices/veiculos/default.aspx?azxp=1&azxp=1%2c+1&v=m&p=52',
        {
          headers => {
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
            'Referer'         => 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?azxp=1&azxp=1%2C+1&v=m&p=52',
            'User-Agent'      => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:20.0) Gecko/20100101 Firefox/20.0',
            'X-MicrosoftAjax' => 'Delta=true',
          },
          content => POST( 'url...', [], Content => $form )->content,
        }
      ]
    } );    
  }
}

sub busca_modelo {
  my ( $self ) = @_; 
# warn $self->robot->useragent->content_type;
  my $anos = $self->tree->findnodes( '//select[@name="ddlAnoValor"]/option' );
  foreach my $ano ( $anos->get_nodelist ) {
    my $kv = {};
    $kv->{ ano_id }     = $ano->attr( 'value' );
    $kv->{ ano }        = $ano->as_text;
    $kv->{ modelo_id }  = $self->robot->reader->passed_key_values->{ modelo_id };
    $kv->{ modelo }     = $self->robot->reader->passed_key_values->{ modelo };
    $kv->{ marca_id }   = $self->robot->reader->passed_key_values->{ marca_id };
    $kv->{ marca }      = $self->robot->reader->passed_key_values->{ marca };
    next unless $ano->as_text !~ m/selecione/ig;
    my ( $captura1, $viewstate )         = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.*)__VIEWSTATE\|([^\|]+)\|/g;
    my ( $captura_1, $event_validation ) = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.*)__EVENTVALIDATION\|([^\|]+)\|/g;
  $self->viewstate( $viewstate );
  $self->eventvalidation( $event_validation );
#   warn $self->robot->reader->passed_key_values->{ modelo };
#   warn $self->robot->reader->passed_key_values->{ marca };
#   warn $self->robot->reader->passed_key_values->{ ano };
# warn p $kv;
    my $form = [
      'ScriptManager1'      => 'updAnoValor|ddlAnoValor',
      '__ASYNCPOST'         => 'true',
      '__EVENTARGUMENT'     => '',
      '__EVENTTARGET'       => 'ddlAnoValor',
      '__EVENTVALIDATION'   => $self->eventvalidation,
      '__LASTFOCUS'         => '',
      '__VIEWSTATE'         => $self->viewstate,
      'ddlAnoValor'         => $kv->{ ano_id },
      'ddlMarca'            => $kv->{ marca_id },
      'ddlModelo'           => $kv->{ modelo_id },
      'ddlTabelaReferencia' => '154',
      'tctCodFipe'          => '',
    ];
#   warn $kv->{ ano };
#   warn $kv->{ marca };
#   warn $kv->{ modelo };
#   warn $kv->{ ano_id };
#   warn $kv->{ marca_id };
#   warn $kv->{ modelo_id };


    $self->prepend( busca_ano => '', {
      passed_key_values => $self->robot->reader->passed_key_values,
      request => [
        'POST',
        'http://www.fipe.org.br/web/indices/veiculos/default.aspx?azxp=1%2c+1&v=m&p=52',
        {
          headers => {
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
            'Referer'         => 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?azxp=1&azxp=1%2C+1&v=m&p=52',
            'User-Agent'      => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:20.0) Gecko/20100101 Firefox/20.0',
            'X-MicrosoftAjax' => 'Delta=true',
          },
          content => POST( 'url...', [], Content => $form )->content,
        }
      ]
    } );    
  }
}

sub busca_ano {
  my ( $self ) = @_; 
  warn p $self->robot->useragent->content;
  my $item = {};
  warn p $self->robot->reader->passed_key_values;
  $item->{ mes_referencia }   = $self->tree->findvalue('//span[@id="lblReferencia"]') ;
  $item->{ cod_fipe }         = $self->tree->findvalue('//span[@id="lblCodFipe"]');
  $item->{ marca }            = $self->tree->findvalue('//span[@id="lblMarca"]');
  $item->{ modelo }           = $self->tree->findvalue('//span[@id="lblModelo"]');
  $item->{ ano }              = $self->tree->findvalue('//span[@id="lblAnoModelo"]');
  $item->{ preco }            = $self->tree->findvalue('//span[@id="lblValor"]');
  $item->{ data }             = $self->tree->findvalue('//span[@id="lblData"]');

  warn $self->robot->writer->write( $item );
    
  warn p $item;
sleep 1;
# warn p $self->robot->queue->engine->url_list;
}

sub on_link {
    my ( $self, $url ) = @_;
}

sub on_finish {
    my ( $self ) = @_; 
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

