package SVG::TT::Graph;

use strict;
use Carp;
use vars qw($VERSION $AUTOLOAD);
use Template;

$VERSION = '0.02';

# set up TT object
my %config = (
	POST_CHOMP => 1,
	INCLUDE_PATH	=> '/',
);	
my $tt = Template->new( \%config );

=head1 NAME

SVG::TT::Graph - Base object for generating SVG Graphs

=head1 SYNOPSIS

  package SVG::TT::Graph::GRAPH_TYPE
  use SVG::Graph;
  use base qw(SVG::TT::Graph);

  sub _set_defaults {
    my $self = shift;

    my %default = (
        'keys'  => 'value',
    );
    while( my ($key,$value) = each %default ) {
      $self->{config}->{$key} = $value;
    }
  }

  sub get_template {
    my $self = shift;
    # read in template
    my $template = 'set the template';
    return $template;
  }
  
  # optional - called when object is created
  sub _init {
    my $self = shift;
	# any testing you want to do.
  
  }
  
  1;
  
  In your script...
  
  use SVG::TT::Graph::GRAPH_TYPE;
  
  my $width = '500',
  my $heigh = '300',
  my @xfields = qw(field_1 field_2 field_3);
  
  my $graph = SVG::TT::Graph::GRAPH_TYPE->new({
    # Required for some graph types
    'xfields'           => \@xfields,
    # .. other config options
    'height' => '500',
  });
  
  my @data = qw(23 56 32);
  $graph->add_data({
  	'data' => \@data,
	'title' => 'Sales 2002',
  });
  
  # find a config options value
  my $config_value = $graph->config_option();
  # set a config option value
  $graph->config_option($config_value);
    
  print "Content-type: image/svg+xml\r\n";
  print $graph->burn();

=head1 DESCRIPTION

This package should be used as a base for creating SVG graphs.

See SVG::TT::Graph::Line for an example.

=cut

sub new {
	my ($proto,$conf) = @_;
    my $class = ref($proto) || $proto;
    my $self = {};

    bless($self, $class);

	if($self->can('_set_defaults')) {
		# Populate with local defaults
		$self->_set_defaults();
	} else {
		croak "$class should have a _set_defaults method";
	}
		
	# overwrite defaults with user options
	while( my ($key,$value) = each %{$conf} ) {
		$self->{config}->{$key} = $value;
	}

	# Allow the inheriting modules to do checks
	if($self->can('_init')) {
		$self->_init();
	}
	
	return $self;
}

=head1 METHODS

=head2 add_data()

  my @data_sales_02 = qw(12 45 21);

  $graph->add_data({
    'data' => \@data_sales_02,
    'title' => 'Sales 2002',
  });

This method allows you do add data to the graph object.
It can be called several times to add more data sets in.

=cut
  
sub add_data {
	my ($self, $conf) = @_;
	# create an array
	unless(defined $self->{'data'}) {
		my @data;
		$self->{'data'} = \@data;
	}
	
	croak 'no xfields array ref' 
	unless defined $self->{'config'}->{'xfields'} 
	&& ref($self->{'config'}->{'xfields'}) eq 'ARRAY';

	if(defined $conf->{'data'} && ref($conf->{'data'}) eq 'ARRAY') {
		my %new_data;
		@new_data{@{$self->{'config'}->{'xfields'}}} = @{$conf->{'data'}};
		my %store = (
			'data' => \%new_data,
		);
		$store{'title'} = $conf->{'title'} if defined $conf->{'title'};
		push (@{$self->{'data'}},\%store);
		return 1;
	}
	return undef;
}

=head2 clear_data()

  my $graph->clear_data();

This method removes all data from the object so that you can
reuse it to create a new graph but with the same config options.

=cut

sub clear_data {
	my $self = shift;
	my @data;
	$self->{'data'} = \@data;
}

=head2 burn()

  print $graph->burn();

This method processes the template with the data and
config which has been set and returns the resulting SVG.

This method will croak unless at least one data set has
been added to the graph object.

=cut

sub burn {
	my $self = shift;
	
	# Check we have at least one data value
	croak "No data available" 
		unless scalar(@{$self->{'data'}}) > 0;	

	croak ref($self) . ' must have a get_template method.' 
		unless $self->can('get_template');
	
	my $template = $self->get_template();
	
	my %vals = (
		'data'		=> $self->{'data'},
		'config'	=> $self->{'config'},
		'sin'		=> \&_sin_it,
		'cos'		=> \&_cos_it,
	);
	
	# euu - hack!! - maybe should just be a method 
	$self->{sin} = \&_sin_it;
	$self->{cos} = \&_cos_it;
	
	my $file;
	my $template_responce = $tt->process( \$template, \%vals, \$file );

	if($tt->error()) {
		require Data::Dumper;
		croak "Template error: " . $tt->error . "\n" . Dumper($self) if $tt->error;
	}
	return $file;
}

sub _sin_it {
	return sin(shift);
}

sub _cos_it {
	return cos(shift);
}

=head2 config methods

  my $value = $graph->method();
  $graph->method($value);

This object provides autoload methods for all config
options defined in the _set_default method within the
inheriting object.

See the SVG::TT::Graph::GRAPH_TYPE documentation for a list.

=cut

## AUTOLOAD FOR CONFIG editing

sub AUTOLOAD {
	my $name = $AUTOLOAD;
	$name =~ s/.*://;

	croak "No object supplied" unless $_[0];
	if(defined $_[0]->{'config'}->{$name}) {
		if(defined $_[1]) {
			# set the value
			$_[0]->{'config'}->{$name} = $_[1];
		}
		return $_[0]->{'config'}->{$name} if defined $_[0]->{'config'}->{$name};
		return undef;
	} else {
		croak "Method: $name can not be used with " . ref($_[0]);
	}
}

# As we have AUTOLOAD we need this
sub DESTROY {
}

1;
__END__

=head1 EXAMPLES

For examples look at the project home page 
http://leo.cuckoo.org/projects/SVG-TT-Graph/

=head1 EXPORT

None by default.

=head1 ACKNOWLEDGEMENTS

Thanks to Foxtons for letting us put this on CPAN.

=head1 AUTHOR

Leo Lapworth (LLAP@cuckoo.org)

=head1 SEE ALSO

L<SVG::TT::Graph::Line>,
L<SVG::TT::Graph::BarHorizontal>,
L<SVG::TT::Graph::Pie>,

=head1 COPYRIGHT

Copyright (C) 2003, Leo Lapworth 

This module is free software; you can redistribute it or 
modify it under the same terms as Perl itself. 

=cut
