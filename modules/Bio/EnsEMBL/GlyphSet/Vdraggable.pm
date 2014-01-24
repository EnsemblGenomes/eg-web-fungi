package Bio::EnsEMBL::GlyphSet::Vdraggable;

use strict;

use base qw(Bio::EnsEMBL::GlyphSet);

sub render_normal {
  my ($self) = @_;

  my $chr = $self->{'container'}{'chr'};
  my $slice_adaptor = $self->{'container'}->{'sa'};
  my $slice = $slice_adaptor->fetch_by_region(undef, $chr);
  my $len   = $slice->length;
  my $c_w   = $self->get_parameter('container_width');
  my $glyph = $self->Space({
    'x'         => $c_w - $len,
    'y'         => 0,
    'width'     => $len,
    'height'    => 1,
    'absolutey' => 1,
  });


  $self->push($glyph);
  my $A = $self->my_config('part');

  my $species_path = $self->{'config'}->species_defs->species_path($self->species);
  $species_path =~ s/\//\-/g;
  $species_path =~ s/^-//;

  my $href = join '|',
    '#vdrag', $self->get_parameter('slice_number') || 1, $species_path,
    $chr,
    1, $len, 1;

  my @common = ( 
    'y'     => $A,
    'style' => 'fill', 
    'z'     => -10,
    'href'  => $href, 
    'class' => 'vdrag'
  );
  
  $self->join_tag($glyph, 'draggable', { 'x' => $A, @common });
  $self->join_tag($glyph, 'draggable', { 'x' => 1 - $A, @common });
}

1;
