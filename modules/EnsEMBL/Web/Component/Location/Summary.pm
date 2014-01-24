package EnsEMBL::Web::Component::Location::Summary;

use Image::Size;

sub content {
  my $self   = shift;
  my $object = $self->object;
  
  return '' unless $object && $object->seq_region_name;
  
  my $slice = $object->database('core')->get_SliceAdaptor->fetch_by_region(
    $object->seq_region_type, $object->seq_region_name, 1, $object->seq_region_length, 1
  );
 
  unless($slice->is_circular) {
 
      my $image_config = $object->get_imageconfig('chromosome');
  
      $image_config->set_parameters({
        container_width => $object->seq_region_length,
        image_width     => $self->image_width,
        slice_number    => '1|1'
      });

      if ($image_config->get_node('annotation_status')) {
        $image_config->get_node('annotation_status')->set('caption', '');
        $image_config->get_node('annotation_status')->set('menu', 'no');
      };

      $image_config->get_node('ideogram')->set('caption', $object->seq_region_type . ' ' . $object->seq_region_name );
  
      my $image = $self->new_image($slice, $image_config);
  
      return if $self->_export_image($image);
  
      $image->imagemap = 'yes';
      $image->{'panel_number'} = 'context';
      $image->set_button('drag', 'title' => 'Click or drag to centre display');
  
      return $image->render;
  } 
  

  my $species   = $object->species;
  my $spec_short_name = $species;
  $spec_short_name =~ s/\_/ /g;
  $spec_short_name = "\u$spec_short_name";

  my $chr_name  = $object->seq_region_name;
  my $img = 'region_'.$species.'_'.$chr_name.'.png';
  my $region_name = $object->seq_region_name;

  # get the image size                                                                                                                                                                                         
  my ($width, $height) = imgsize(${SiteDefs::ENSEMBL_SERVERROOT}.'/eg-plugins/fungi/htdocs/img/species/'.$img);

  # for test purposes
  $img = 'region_e_coli_k12_Chromosome.png' if ((!$width) && (!$height));

  if (((!$width) && (!$height)) || (($width>220) && ($height>220))) {
      $width =  220;
      $height = 220;
  } elsif($width < 100) {
      $width = $width + 1/2*$width;
      $height = $height + 1/2*$height;
  }

  return '<input class="panel_type" type="hidden" value="IdeogramPanel" />                                                                                                          
           <span class="labelImg" style="display:block;margin:auto;width:400px;text-align:center;font-size:10px;">                                                                     
            '.$spec_short_name.'<br>'.$region_name.'                                                                                                                                    
           <div style="width:'.$width.'px;height:'.$height.'px;margin: 0px auto 10px auto;"><img class="circularImage" height="'.$height.'" width="'.$width.'" alt="Click and drag the handles to select a region" id="'.$region_name.'~'.$object->seq_region_length.'~9~0" src="/img/species/'.$img.'" border="0"></div>                                                                                   
            <div class="labelDiv" style="visibility: hidden; font-size: 10px; padding-bottom: 4px;">Drag the handles to select a region and click on selected region to update location</div>   
          </span>';

}

1;
