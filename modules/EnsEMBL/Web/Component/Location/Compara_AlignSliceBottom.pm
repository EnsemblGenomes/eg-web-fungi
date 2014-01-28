=head1 LICENSE

Copyright [2009-2014] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

# $Id: Compara_AlignSliceBottom.pm,v 1.2 2011-06-22 10:25:54 it2 Exp $

package EnsEMBL::Web::Component::Location::Compara_AlignSliceBottom;

sub content {
  my $self         = shift;
  my $hub          = $self->hub;
  my $species_defs = $hub->species_defs;
  my $object       = $self->object;
  my $threshold    = 1000100 * ($species_defs->ENSEMBL_GENOME_SIZE || 1);
  my $align_params = $hub->param('align');
  my ($align)      = split '--', $align_params;
  
  my ($align, undef, $target_slice_name) = split '--', $align_params;
  
  return $self->_warning('Region too large', '<p>The region selected is too large to display in this view - use the navigation above to zoom in...</p>') if $object->length > $threshold;
  return $self->_info('No alignment specified', '<p>Select the alignment you wish to display from the box above.</p>') unless $align;
  
  my $align_details = $species_defs->multi_hash->{'DATABASE_COMPARA'}->{'ALIGNMENTS'}->{$align};

  return $self->_error('Unknown alignment', '<p>The alignment you have select does not exist in the current database.</p>') unless $align_details;
  
  my $primary_species = $hub->species;
  
  if (!exists $align_details->{'species'}->{$primary_species}) {
    return $self->_error('Unknown alignment', sprintf(
      '<p>%s is not part of the %s alignment in the database.</p>',
      $species_defs->species_label($primary_species),
						      encode_entities($align_details->{'name'})
						      ));
  }
  
  my $image_width = $self->image_width;
  my $slice = $object->slice;
  my ($slices) = $self->get_slices($slice, $align_params, $primary_species);
  my %aligned_species = map { $_->{'name'} => 1 } @$slices;
  my $i               = 1;
  my (@skipped, @missing, @images, $html, $info);

  foreach (keys %{$align_details->{'species'}}) {
    next if $_ eq $primary_species;

    if ($align_details->{'class'} !~ /pairwise/ && ($hub->param(sprintf 'species_%d_%s', $align, lc) || 'off') eq 'off') {
      push @skipped, $_;
    } elsif (!$aligned_species{$_} && $_ ne 'ancestral_sequences') {
      push @missing, $_;
    }
  }
  
  my $numsl = @$slices;
  $numsl = int($numsl/2) if(($slice->start > $slice->end) && ($numsl > 1));

  foreach (@$slices) {
    my $species      = $_->{'name'} eq 'Ancestral_sequences' ? 'Multi' : $_->{'name'}; # Cheating: set species to Multi to stop errors due to invalid species
    my $image_config = $hub->get_imageconfig('alignsliceviewbottom', "alignsliceviewbottom_$i", $species); 
  
    my $splitflag = ($slice->start > $slice->end) ? (($i <= $numsl ) ? 1 : 2) : 0;  #used in alignscalebar.pm, draggable.pm, ZMenu                                          
    my $slicelen  = ($slice->start > $slice->end) ? $slice->seq_region_length : 0;  #used in draggable.pm, ZMenu                                     

    $image_config->set_parameters({
      container_width => $_->{'slice'}->length,
      image_width     => $image_width || 800, # hack at the moment
      slice_number    => "$i|3",
      compara         => $i == 1 ? 'primary' : 'secondary',
      splitflag       => $splitflag,
      slicelen        => $slicelen
    });
    
    my ($species_name, $slice_name) = split ':', $_->{'name'};

    my $panel_caption = $species_defs->get_config($species_name, 'SPECIES_COMMON_NAME') || 'Ancestral sequences';
    $panel_caption   .= " $slice_name" if $slice_name;

    $image_config->get_node('alignscalebar')->set('caption', $panel_caption);

    push @images, $_->{'slice'}, $image_config;
    $i++;
  }
  my $image = $self->new_image(\@images);

  return if $self->_export_image($image);

  $image->{'panel_number'} = 'bottom';
  $image->imagemap = 'yes';
  $image->set_button('drag', 'title' => 'Click or drag to centre display');

  $html .= $image->render;

  if (scalar @skipped) {
    $info .= sprintf(
      '<p>The following %d species in the alignment are not shown in the image. Use the "<strong>Configure this page</strong>" on the left to show them.<ul><li>%s</li></ul></p>',
      scalar @skipped,
      join "</li>\n<li>", sort map $species_defs->species_label($_), @skipped
		     );
  }

  if (scalar @missing) {
      if ($align_details->{'class'} =~ /pairwise/) {
	  $info .= sprintf '<p>%s has no alignment in this region</p>', $species_defs->species_label($missing[0]);
      } else {
        $info .= sprintf(
        '<p>The following %d species have no alignment in this region:<ul><li>%s</li></ul></p>',
        scalar @missing,
        join "</li>\n<li>", sort map $species_defs->species_label($_), @missing
		       );
      }
  }

  $html .= $self->_info('Notes', $info) if $info;
  
  return $html;
}

1;
