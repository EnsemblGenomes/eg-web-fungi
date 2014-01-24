package Bio::EnsEMBL::GlyphSet::chr_band;

use strict;
use warnings;
no warnings 'uninitialized';

use base qw(Bio::EnsEMBL::GlyphSet);

my %SHORT = qw(
  'chromosome'  "Chr."
  'supercontig' "S'ctg"
);

sub _init {
  my ($self) = @_;
  
  return $self->render_text if $self->{'text_export'};
  
  ########## only draw contigs once - on one strand

  my $col    = undef;
  my $config = $self->{'config'};
  my $white  = 'white';
  my $black  = 'black';

  my $start_point = $self->{'container'}->start;
  my $end_point = $self->{'container'}->end;
  my $reg_end = $self->{'container'}->seq_region_length;
  my $addition = 0;
 
  my $no_sequence = $self->{'config'}->species_defs->NO_SEQUENCE;

  my @t_stains = qw(gpos25 gpos75);
  
  my $im_width = $self->{'config'}->image_width();
   
  my $prev_end = 0;
  # fetch the chromosome bands that cover this VC.
  my $bands = $self->{'container'}->get_all_KaryotypeBands();
  my $min_start;
  my $max_end; 
  my( $fontname, $fontsize ) = $self->get_font_details( 'innertext' );
  my @res = $self->get_text_width( 0, 'X', '', 'font'=>$fontname, 'ptsize' => $fontsize );
  my $h = $res[3];
  my $pix_per_bp = $self->{'config'}->transform()->{'scalex'};

  my @t_colour = qw(gpos25 gpos75);
  my $chr = @$bands ? $bands->[0]->slice()->seq_region_name() : '';
  my @bands;
    @bands =  sort{$a->start <=> $b->start } @$bands;

  
  my $last_color=0;
  my %color_alt1 = ( 'grey60' => 'white', 'white' => 'grey60' );
  my %color_alt2 = ( 'black' =>'white', 'white' => 'black' );
  

  foreach my $band (@bands) {
    my $bandname = $band->name();
       $bandname =~ /(\d+)\w?/;
    my $band_no = $1;
    my $start = $band->start();
    my $end = $band->end();
    my $stain = $band->stain();


    my $vc_band_start = $start;
    my $vc_band_end   = $end;

    $vc_band_start    = 1 if ($vc_band_start < 1);
    if($start_point <= $end_point) {
           $vc_band_end      =  $self->{'container'}->length() if ($vc_band_end > $self->{'container'}->length());
    }  
    if (($start_point > $end_point) && ($start >= 1) && ($vc_band_end > $end_point))  {
           $vc_band_end  =  $end_point;
    }

    my $min_start = $vc_band_start if(!defined $min_start || $min_start > $vc_band_start); 
    my $max_end   = $vc_band_end   if(!defined $max_end   || $max_end   < $vc_band_end); 

    my $col = $self->my_colour( $stain );
    my $fontcolour = $self->my_colour( $stain,'label' ) || 'black';
    unless( $stain ) {
      $stain = shift @t_colour;
      $col = $self->my_colour( $stain );
      $fontcolour = $self->my_colour( $stain,'label' );
      push @t_colour, ($stain = shift @t_colour);
    }

    if ($start_point>$end_point) {
	if(!$last_color) {
            $last_color = $col; 
        } elsif (($last_color eq $col) && $color_alt1{$col}) {
            $col = $color_alt1{$col};
	    if( $fontcolour ne 'invisible' )  {
                if($color_alt2{$fontcolour}) {
                  $fontcolour = $color_alt2{$fontcolour};
	        } else {
		  $fontcolour = 'black';  
                }
            }
        }
        $last_color = $col;
    }

    if(($start_point>$end_point) && ($start >= 1)) {
	$addition = $reg_end - $start_point + 1;
    } else {
	$addition = 0;
    }

    $self->push($self->Rect({
      'x'      => $vc_band_start + $addition - 1,
      'y'      => 0,
      'width'  => $vc_band_end - $vc_band_start + 1,
      'height' => $h + 4,
      'colour' => $col || 'white',
      'absolutey' => 1,
    }));
    
    
    if( $fontcolour ne 'invisible' ) {
      my @res = $self->get_text_width( ($vc_band_end-$vc_band_start +1)*$pix_per_bp, $bandname, '', 'font'=>$fontname, 'ptsize' => $fontsize );
      #only add the lable if the box is big enough to hold it...

      if( $res[0] ) {

        $self->push($self->Text({
          'x'      => ($vc_band_end + $vc_band_start + 2*$addition -1 - $res[2]/$pix_per_bp)/2,        #add $addition both to $vc_band_end and to $vc_band_start
          'y'      => 1,
          'width'  => $res[2]/$pix_per_bp,
          'textwidth' => $res[2],
          'font'   => $fontname,
          'height' => $h,
          'ptsize' => $fontsize,
          'colour' => $fontcolour,
          'text'   => $res[0],
          'absolutey'  => 1,
        }));
      }
    }
    my $vc_adjust  = 1 - $self->{'container'}->start ;
    my ($band_start, $band_end);
    if (($start_point>$end_point) && ($start >= 1)) {
        $band_start = $band->{'start'};
        $band_end   = $band->{'end'}; 
    } else {
        $band_start = $band->{'start'} - $vc_adjust;
        $band_end   = $band->{'end'}   - $vc_adjust;
    }
  

    $self->push($self->Rect({
      'x'             => $min_start + $addition -1,
      'y'             => 0,
      'width'         => $max_end - $min_start + 1,
      'height'        => $h + 4 ,
      'bordercolour'  => $black,
      'absolutey'     => 1,
      'title'         => "Band: $bandname",
      'href'          => $self->_url({'r'=>"$chr:$band_start-$band_end"})
    }));
  }


}

sub render_text {
  my $self = shift;
  
  my @bands =  sort { $a->start <=> $b->start } @{$self->{'container'}->get_all_KaryotypeBands||[]};
  my $export;
  
  foreach (@bands) {
    $export .= $self->_render_text($_, 'Chromosome band', { 
      'headers' => [ 'name' ], 
      'values'  => [ $_->name ] 
    });
  }
  
  return $export;
}
1;
