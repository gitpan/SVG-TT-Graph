package SVG::TT::Graph::BarHorizontal;

use strict;
use Carp;
use vars qw($VERSION);
$VERSION = '0.02';

use SVG::TT::Graph;
use base qw(SVG::TT::Graph);

# Nasty global! to store the template in, someone patch
# please, so that reading from __DATA__ works even if you
# do it twice from the same script!
my $template;

=head1 NAME

SVG::TT::Graph::BarHorizontal - Create presentation quality SVG horitonzal bar graphs easily

=head1 SYNOPSIS

  use SVG::TT::Graph::BarHorizontal;

  my @fields = qw(Jan Feb Mar);
  my @data_sales_02 = qw(12 45 21);
  
  my $graph = SVG::TT::Graph::BarHorizontal->new({
  	'height' => '500',
	'width' => '300',
	'xfields' => \@fields,
  });
  
  $graph->add_data({
  	'data' => \@data_sales_02,
	'title' => 'Sales 2002',
  });
  
  print "Content-type: image/svg+xml\r\n";
  print $graph->burn();

=head1 DESCRIPTION

This object aims to allow you to easily create high quality
SVG horitonzal bar graphs. You can either use the default style sheet
or supply your own. Either way there are many options which can
be configured to give you control over how the graph is
generated - with or without a key, data elements at each point,
title, subtitle etc.

=head1 METHODS

=head2 new()

  use SVG::TT::Graph::BarHorizontal;
  
  # Field names along the X axis
  my @fields = qw(Jan Feb Mar);
  
  my $graph = SVG::TT::Graph::BarHorizontal->new({
    # Required
    'xfields' => \@fields,
  
    # Optional - defaults shown
    'height'            => '500',
    'width'             => '300',

    'show_data_values'  => 1,

    'y_marker'          => '20',
    'y_start'           => '0',

    'show_x_labels'     => 1,
    'show_y_labels'     => 1,

    'show_x_title'      => 0,
    'x_title'           => 'X Field names',

    'show_y_title'      => 0,
    'y_title'           => 'Y Scale',

    'show_graph_title'		=> 0,
    'graph_title'           => 'Graph Title',
    'show_graph_subtitle'	=> 0,
    'graph_subtitle'		=> 'Graph Sub Title',

    # Optional - defaults to using embeded stylesheet
    'style_sheet'       => '/includes/graph.css',
  });

The constructor takes a hash reference, only xfields (the names for each
field on the X axis) MUST be set, all other values are defaulted to those
shown above - with the exception of style_sheet which defaults
to using the internal style sheet.

=head2 add_data()

  my @data_sales_02 = qw(12 45 21);

  $graph->add_data({
    'data' => \@data_sales_02,
    'title' => 'Sales 2002',
  });

This method allows you to add data to the graph object.
It can be called several times to add more data sets in,
but the likely hood is you should be using SVG::TT::Graph::Line
as it won't look great!

=head2 clear_data()

  my $graph->clear_data();

This method removes all data from the object so that you can
reuse it to create a new graph but with the same config options.

=head2 burn()

  print $graph->burn();

This method processes the template with the data and
config which has been set and returns the resulting SVG.

This method will croak unless at least one data set has
been added to the graph object.

=head2 config methods

  my $value = $graph->method();
  my $confirmed_new_value = $graph->method($value);
  
The following is a list of the methods which are available
to change the config of the graph object after it has been
created.

=over 4

=item height()

Set the height of the graph box, this is the total height
of the SVG box created - not the graph it self which auto
scales to fix the space.

=item width()

Set the width of the graph box, this is the total height
of the SVG box created - not the graph it self which auto
scales to fix the space.

=item style_sheet()

Set the path to an external stylesheet, set to '' if
you want to revert back to using the defaut embeded version.

To create an external stylesheet create a graph using the
default embeded version and copy the stylesheet section to
an external file and edit from there.

=item show_data_values()

Show the value of each element of data on the graph

=item y_start()

The point at which the Y axis starts, defaults to '0',
if set to '' it will default to the minimum data value.

=item y_marker()

This defines the gap between markers on the Y axis,
default is a 10th of the max_value, e.g. you will have
10 markers on the Y axis.

=item show_x_labels()

Whether to show labels on the X axis or not, defaults
to 1, set to '0' if you want to turn them off.

=item show_y_labels()

Whether to show labels on the Y axis or not, defaults
to 1, set to '0' if you want to turn them off.

=item show_x_title()

Whether to show the title under the X axis labels,
default is 0, set to '1' to show.

=item x_title()

What the title under X axis should be, e.g. 'Months'.

=item show_y_title()

Whether to show the title under the Y axis labels,
default is 0, set to '1' to show.

=item y_title()

What the title under Y axis should be, e.g. 'Sales in thousands'.

=item show_graph_title()

Whether to show a title on the graph,
default is 0, set to '1' to show.

=item graph_title()

What the title on the graph should be.

=item show_graph_subtitle()

Whether to show a subtitle on the graph,
default is 0, set to '1' to show.

=item graph_subtitle()

What the subtitle on the graph should be.

=item key()

Whether to show a key, defaults to 0, set to
'1' if you want to show it.

=item key_position()

Where the key should be positioned, defaults to
'right', set to 'bottom' if you want to move it.

=back

=head1 NOTES

The default stylesheet handles upto 10 data sets, if you
use more you must create your own stylesheet and add the
additional settings for the extra data sets. You will know
if you go over 10 data sets as they will have no style and
be in black.

=head1 EXAMPLES

For examples look at the project home page 
http://leo.cuckoo.org/projects/SVG-TT-Graph/

=head1 EXPORT

None by default.

=head1 ACKNOWLEDGEMENTS

Stephen Morgan for creating the TT template and SVG.

=head1 AUTHOR

Leo Lapworth (LLAP@cuckoo.org)

=head1 SEE ALSO

L<SVG::TT::Graph>,
L<SVG::TT::Graph::Line>,
L<SVG::TT::Graph::Bar>,
L<SVG::TT::Graph::Pie>,


=cut

sub get_template {
	my $self = shift;
	# read in template
	return $template if $template;
	while(<DATA>) {
		$template .= $_ . "\r\n";
	}
	return $template;
}

sub _init {
	my $self = shift;
	croak "xfields was not supplied or is empty" 
	unless defined $self->{'config'}->{xfields} 
	&& ref($self->{'config'}->{xfields}) eq 'ARRAY'
	&& scalar(@{$self->{'config'}->{xfields}}) > 0;
}

sub _set_defaults {
	my $self = shift;
	
	my %default = (
		'width'				=> '500',
		'height'			=> '300',
		'style_sheet'       => '',
	    'show_data_values'  => 1,
	
	    'y_start'           => '0',

	    'show_x_labels'     => 1,
	    'show_y_labels'     => 1,
	
	    'show_x_title'      => 0,
	    'x_title'           => 'X Field names',
	
	    'show_y_title'      => 0,
	    'y_title'           => 'Y Scale',
	
	    'show_graph_title'		=> 0,
	    'graph_title'			=> 'Graph Title',
	    'show_graph_subtitle'	=> 0,
	    'graph_subtitle'		=> 'Graph Sub Title',
		'key'					=> 0, 
		'key_position'			=> 'right', # bottom or right
	);
	
	while( my ($key,$value) = each %default ) {
		$self->{config}->{$key} = $value;
	}
}

1;
__DATA__
<?xml version="1.0"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN"
	"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
[% stylesheet = 'included' %]

[% IF config.style_sheet && config.style_sheet != '' %]
	<?xml-stylesheet href="[% config.style_sheet %]" type="text/css"?>	
[% ELSE %]
	[% stylesheet = 'excluded' %]
[% END %]

<svg width="[% config.width %]" height="[% config.height %]" viewBox="0 0 [% config.width %] [% config.height %]" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">

[% IF stylesheet == 'excluded' %]
<!-- include default stylesheet if none specified -->
<defs>
<style type="text/css">
<![CDATA[
.svgBackground{
	fill:#ffffff;
}
.graphBackground{
	fill:#f0f0f0;
}

/* graphs titles */
.mainTitle{
	text-anchor: middle;
	fill: #000000;
	font-size: 14px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}
.subTitle{
	text-anchor: middle;
	fill: #999999;
	font-size: 12px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.axis{
	stroke: #000000;
	stroke-width: 1px;
}

.guideLines{
	stroke: #666666;
	stroke-width: 1px;
	stroke-dasharray: 5 5;
}

.xAxisLabels{
	text-anchor: middle;
	fill: #000000;
	font-size: 12px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.yAxisLabels{
	text-anchor: end;
	fill: #000000;
	font-size: 12px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.xAxisTitle{
	text-anchor: middle;
	fill: #ff0000;
	font-size: 14px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.yAxisTitle{
	fill: #ff0000;
	writing-mode: tb; 
	glyph-orientation-vertical: 0;
	text-anchor: middle;
	font-size: 14px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.dataPointLabel{
	fill: #000000;
	text-anchor:middle;
	font-size: 10px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

/* default fill styles */
.fill1{
	fill: #cc0000;
	fill-opacity: 0.2;
	stroke: none;
}
.fill2{
	fill: #0000cc;
	fill-opacity: 0.2;
	stroke: none;
}
.fill3{
	fill: #00cc00;
	fill-opacity: 0.2;
	stroke: none;
}
.fill4{
	fill: #ffcc00;
	fill-opacity: 0.2;
	stroke: none;
}
.fill5{
	fill: #00ccff;
	fill-opacity: 0.2;
	stroke: none;
}
.fill6{
	fill: #ff00ff;
	fill-opacity: 0.2;
	stroke: none;
}
.fill7{
	fill: #00ffff;
	fill-opacity: 0.2;
	stroke: none;
}
.fill8{
	fill: #ffff00;
	fill-opacity: 0.2;
	stroke: none;
}
.fill9{
	fill: #cc6666;
	fill-opacity: 0.2;
	stroke: none;
}
.fill10{
	fill: #663399;
	fill-opacity: 0.2;
	stroke: none;
}
/* default line styles */
.line1{
	fill: none;
	stroke: #ff0000;
	stroke-width: 1px;	
}
.line2{
	fill: none;
	stroke: #0000ff;
	stroke-width: 1px;	
}
.line3{
	fill: none;
	stroke: #00ff00;
	stroke-width: 1px;	
}
.line4{
	fill: none;
	stroke: #ffcc00;
	stroke-width: 1px;	
}
.line5{
	fill: none;
	stroke: #00ccff;
	stroke-width: 1px;	
}
.line6{
	fill: none;
	stroke: #ff00ff;
	stroke-width: 1px;	
}
.line7{
	fill: none;
	stroke: #00ffff;
	stroke-width: 1px;	
}
.line8{
	fill: none;
	stroke: #ffff00;
	stroke-width: 1px;	
}
.line9{
	fill: none;
	stroke: #ccc6666;
	stroke-width: 1px;	
}
.line10{
	fill: none;
	stroke: #663399;
	stroke-width: 1px;	
}

/* default line styles */
.key1,.dataPoint1{
	fill: #ff0000;
	stroke: none;
	stroke-width: 1px;	
}
.key2,.dataPoint2{
	fill: #0000ff;
	stroke: none;
	stroke-width: 1px;	
}
.key3,.dataPoint3{
	fill: #00ff00;
	stroke: none;
	stroke-width: 1px;	
}
.key4,.dataPoint4{
	fill: #ffcc00;
	stroke: none;
	stroke-width: 1px;	
}
.key5,.dataPoint5{
	fill: #00ccff;
	stroke: none;
	stroke-width: 1px;	
}
.key6,.dataPoint6{
	fill: #ff00ff;
	stroke: none;
	stroke-width: 1px;	
}
.key7,.dataPoint7{
	fill: #00ffff;
	stroke: none;
	stroke-width: 1px;	
}
.key8,.dataPoint8{
	fill: #ffff00;
	stroke: none;
	stroke-width: 1px;	
}
.key9,.dataPoint9{
	fill: #cc6666;
	stroke: none;
	stroke-width: 1px;	
}
.key10,.dataPoint10{
	fill: #663399;
	stroke: none;
	stroke-width: 1px;	
}
.keyText{
	fill: #000000;
	text-anchor:start;
	font-size: 10px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}
]]>
</style>
</defs>
[% END %]
<!-- svg bg -->
	<rect x="0" y="0" width="[% config.width %]" height="[% config.height %]" class="svgBackground"/>
	
<!-- ///////////////// CALCULATE GRAPH AREA AND BOUNDARIES //////////////// -->
<!-- get dimensions of actual graph area (NOT SVG area) -->
	[% w = config.width %]
	[% h = config.height %]

	<!-- set start/default coords of graph --> 
	[% x = 0 %]
	[% y = 0 %]
	
<!-- CALC WIDTH AND X COORD DIMENSIONS -->
	<!-- reduce width of graph area if there is labelling on y axis -->
	[% IF config.show_y_labels %][% w = w - 30 %][% x = x + 30 %][% END %]
	[% IF config.show_y_title %][% w = w - 20 %][% x = x + 20 %][% END %]

	<!-- pad ends of graph if there are x labels -->
	[% IF config.show_x_labels %]
		[% w = w - 10 %]
	<!-- if there are no y labels or titles BUT there are x labels, then pad left -->
		[% IF !config.show_y_labels && !config.show_y_title %]
			[% w = w - 10 %]
			[% x = x + 10 %]
		[% END %]
	[% END %]
	

<!-- CALC HEIGHT AND Y COORD DIMENSIONS -->
	<!-- reduce height of graph area if there is labelling on x axis -->
	[% IF config.show_x_labels %][% h = h - 20 %][% END %]
	[% IF config.show_x_title %][% h = h - 25 %][% END %]
	
	<!-- pad top of graph if y axis has data labels so labels do not get chopped off -->
	[% IF config.show_y_labels %][% h = h - 10 %][% y = y + 10 %][% END %]
	
	<!-- reduce height if graph has title or subtitle -->
	[% IF config.show_graph_title %][% h = h - 25 %][% y = y + 25 %][% END %]
	[% IF config.show_graph_subtitle %][% h = h - 10 %][% y = y + 10 %][% END %]

	
<!-- reduce graph dimensions if there is a KEY -->
	[% IF config.key && config.key_position == 'right' %][% w = w - 150 %]
	[% ELSIF config.key && config.key_position == 'bottom' %][% h = h - 50 %]
	[% END %]




<!-- calc min and max values -->
	[% min_value = 99999999 %]
	[% max_value = 0 %]
	[% FOREACH field = config.xfields %]
		[% FOREACH dataset = data %]
			[% IF min_value > dataset.data.$field && dataset.data.$field != '' %]
				[% min_value = dataset.data.$field %]
			[% END %]
			[% IF max_value < dataset.data.$field && dataset.data.$field != '' %]
				[% max_value = dataset.data.$field %]
			[% END %]
		[% END %]
	[% END %]
	
	[% IF config.y_start || config.y_start == '0' %]
		[% y_start = config.y_start %]
	[% ELSE %]
		<!-- setting lowest value to be min_value as no y_start defined -->
		[% y_start = min_value %]
	[% END %]
	
	<!-- base line -->
	[% base_line = h + y %]
	
	<!-- how much padding above max point on graph -->
	[% IF (max_value - y_start) == 0 %]
		[% y_top_pad = 10 %]
	[% ELSE %]
		[% y_top_pad = (max_value - y_start) / 20 %]	
	[% END %]	
	
	[% y_range = (max_value + y_top_pad) - y_start %]

	<!-- setup y_marker - gap between markers -->
	[% IF config.y_marker %]
		[% y_marker = config.y_marker %]
	[% ELSE %]
		[% y_marker = (max_value / 10)  %]
		[% IF max_value > 10 %]
			[% y_marker = y_marker FILTER format('%02.0f') %]
		[% ELSE %]
			[% y_marker = y_marker FILTER format('%02.2f') %]
		[% END %]		
	[% END %]
	
	
<!-- //////////////////////////////  BUILD GRAPH AREA ////////////////////////////// -->
<!-- graph bg -->
	<rect x="[% x %]" y="[% y %]" width="[% w %]" height="[% h %]" class="graphBackground"/>

<!-- axis -->
	<path d="M[% x %] [% y %] v[% h %]" class="axis" id="xAxis"/>
	<path d="M[% x %] [% base_line %] h[% w %]" class="axis" id="yAxis"/>

<!-- //////////////////////////////  AXIS DISTRIBUTIONS //////////////////////////// -->
<!-- get number of data points on y scale -->
[% dy = config.xfields.size %]

<!-- get distribution heights on y axis -->
[% data_widths_y = h / dy %]
[% dh = data_widths_y.match('(\d+[\.\d\d])').0 %]

[% i = dh %]
[% count = 0 %]

<!-- y axis labels -->
[% IF config.show_x_labels %]
	[% FOREACH field = config.xfields %]
		[% IF count == 0 %]
<text x="[% x - 15 %]" y="[% base_line - (dh / 2) %]" class="xAxisLabels">[% field %]</text>
		[% i = i - dh %]
		[% ELSE %]
<text x="[% x - 15 %]" y="[% base_line - i - (dh / 2) %]" class="xAxisLabels">[% field %]</text>
		[% END %]
	[% i = i + dh %]
	[% count = count + 1 %]
	[% END %]
[% END %]


<!-- distribute Y scale -->
[% dx = y_range / y_marker %]
<!-- ensure y_data_points butt up to edge of graph -->
[% y_marker_height = w / dx %]
[% dx = y_marker_height.match('(\d+[\.\d\d])').0 %]
[% count = 0 %]
[% y_value = y_start %]
[% IF config.show_y_labels %]
	[% WHILE (dx * count) < w %]
		[% IF count == 0 %]
		<!-- no stroke for first line -->
			<text x="[% x + (dx * count) %]" y="[% base_line + 15 %]" class="yAxisLabels">[% y_value %]</text>
		[% ELSE %]
			<text x="[% x + (dx * count) %]" y="[% base_line + 15 %]" class="yAxisLabels" style="text-anchor: middle;">[% y_value %]</text>
			<path d="M[% x + (dx * count) %] [% base_line %] V[% y %]" class="guideLines"/>
		[% END %]
		[% y_value = y_value + y_marker %]
		[% count = count + 1 %]
	[% END %]
[% END %]




<!-- //////////////////////////////  AXIS TITLES ////////////////////////////// -->

<!-- y axis title -->
	[% IF config.show_x_title %]
		[% IF !config.show_x_labels %]
			[% y_xtitle = 15 %]
		[% ELSE %]
			[% y_xtitle = 35 %]
		[% END %]
		<text x="[% (w / 2) + x %]" y="[% h + y + y_xtitle %]" class="xAxisTitle">[% config.y_title %]</text>
	[% END %]	

<!-- x axis title -->
	[% IF config.show_y_title %]
			<text x="10" y="[% (h / 2) + y %]" class="yAxisTitle">[% config.x_title %]</text>
	[% END %]




<!-- //////////////////////////////  SHOW DATA ////////////////////////////// -->
[% bar_width = dh - 10 %]

[% divider = dx / y_marker %]
<!-- data points on graph -->
	[% IF config.show_data_points || config.show_data_values%]
		[% xcount = 0 %]
		
		[% FOREACH field = config.xfields %]
		[% dcount = 1 %]

			[% FOREACH dataset = data %]
		<path d="M[% x %] [% base_line - (dh * xcount) - dh %] H[% x + (dataset.data.$field * divider) %] v[% bar_width %] H[% x %] Z" class="fill[% dcount %]"/>

	
			[% IF config.show_data_values %]
		<text x="[% x + (dataset.data.$field * divider) + 5 %]" y="[% base_line - (dh * xcount) - dh + (dh / 2) %]" class="dataPointLabel" style="text-anchor: start;">[% dataset.data.$field %]</text>
			[% END %]
			[% dcount = dcount + 1 %]	
		[% END %]
			[% xcount = xcount + 1 %]		
		[% END %]
	[% END %]



<!-- //////////////////////////////// KEY /////// ////////////////////////// -->
[% key_box_size = 12 %]
[% key_count = 1 %]
[% key_padding = 5 %]
[% IF config.key && config.key_position == 'right' %]
	[% FOREACH dataset = data %]
		<rect x="[% x + w + 20 %]" y="[% y + (key_box_size * key_count) + (key_count * key_padding) %]" width="[% key_box_size %]" height="[% key_box_size %]" class="key[% key_count %]"/>
		<text x="[% x + w + 20 + key_box_size + key_padding %]" y="[% y + (key_box_size * key_count) + (key_count * key_padding) + key_box_size %]" class="keyText">[% dataset.title %]</text>
		[% key_count = key_count + 1 %]
	[% END %]
[% ELSIF config.key && config.key_position == 'bottom' %]
	<!-- calc y position of start of key -->
	[% y_key = base_line %]
	[% IF config.show_x_labels %][% y_key = base_line + 20 %][% END %]
	[% IF config.show_x_title %][% y_key = base_line + 25 %][% END %]
	[% y_key_start = y_key %]
	[% x_key = x %]
	[% FOREACH dataset = data %]
		[% IF key_count == 4 || key_count == 7 || key_count == 10 %]
		<!-- wrap key every 3 entries -->
			[% x_key = x_key + 200 %]
			[% y_key = y_key - (key_box_size * 4) - 2 %]
		[% END %]
		<rect x="[% x_key %]" y="[% y_key + (key_box_size * key_count) + (key_count * key_padding) %]" width="[% key_box_size %]" height="[% key_box_size %]" class="key[% key_count %]"/>

		<text x="[% x_key + key_box_size + key_padding %]" y="[% y_key + (key_box_size * key_count) + (key_count * key_padding) + key_box_size %]" class="keyText">[% dataset.title %]</text>
		[% key_count = key_count + 1 %]
	[% END %]
	
[% END %]
	
<!-- //////////////////////////////// MAIN TITLES ////////////////////////// -->

<!-- main graph title -->
	[% IF config.show_graph_title %]
		<text x="[% w / 2 %]" y="15" class="mainTitle">[% config.graph_title %]</text>
	[% END %]

<!-- graph sub title -->
	[% IF config.show_graph_subtitle %]
		[% IF config.show_graph_title %]
			[% y_subtitle = 30 %]
		[% ELSE %]
			[% y_subtitle = 15 %]
		[% END %]
		<text x="[% w / 2 %]" y="[% y_subtitle %]" class="subTitle">[% config.graph_subtitle %]</text>
	[% END %]
</svg>