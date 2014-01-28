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

package Bio::EnsEMBL::GlyphSet::scalebar;

use strict;
use warnings;
use POSIX qw(floor);

use base qw(Bio::EnsEMBL::GlyphSet);

use Data::Dumper;

sub render {
  my ($self, $y) = @_;

  my $container      = $self->{'container'};
  my $length         = $container->length;
 
  my $contig_strand  = $container->can('strand') ? $container->strand : 1;
  my $pix_per_bp     = $self->scalex;
  
  my $global_start   = $contig_strand < 0 ? -$container->end : $container->start;
  my $global_end     = $contig_strand < 0 ? -$container->start : $container->end;
  my $global_reg_end = $contig_strand < 0 ? -$container->seq_region_length : $container->seq_region_length;

  my $register_line  = $self->get_parameter('opt_lines');
  my $feature_colour = $self->get_parameter('col');
  
  my ($fontname, $fontsize) = $self->get_font_details('innertext');
  my ($major_unit, $minor_unit);

  if ($length <= 51) {
    $major_unit = 10;
    $minor_unit = 1; 
  } else {
    my $exponent = 10 ** int(log($length) / log(10));
    my $mantissa  = $length / $exponent;
    
    if ($mantissa < 1.2) {
      $major_unit = $exponent / 10;
      $minor_unit = $major_unit / 5;
    } elsif ($mantissa < 2.5) {
      $major_unit = $exponent / 5;
      $minor_unit = $major_unit / 4;
    } elsif ($mantissa < 5) {
      $major_unit = $exponent / 2;
      $minor_unit = $major_unit / 5;
    } else {
      $major_unit = $exponent;
      $minor_unit = $major_unit / 5;
    }
  }

  my $last_start;  
  my $start = floor($global_start / $minor_unit) * $minor_unit;
  my $filled = 1;
  my $last_text_x = -1e20;
  my $x_addition = 0;    
  my $www = 0; # Need to check why you get a wierd scalebar in contigview without it

  if( $self->{'container'}->is_circular) {
   
      my $prev_box_start;
      my $prev_height = 0;

      while ($start <= $global_reg_end) {  #$global_end
           $www++;
           last if ($www > 50);
	   my $end       = $start + $minor_unit - 1;
	   my $box_start = $start < $global_start ? $global_start : $start;
           my $box_end   = $end   > $global_reg_end   ? $global_reg_end       : $end;
           my $box_reg_end = $global_reg_end;
        
	   $filled = 1 - $filled;
#warn "\t\t $start : $box_start .. $box_end ( $global_start : $x_addition : $global_reg_end) \n";
           # Draw the glyph for this box (black and white containers)                                                                                                                                        
           my $t = $self->Rect({
           'x'         => $box_start - $global_start + $x_addition,
           'y'         => $y,
           'width'     => abs($box_end - $box_start + 1),
           'height'    => 3,
           ( $filled == 1 ? 'colour' : 'bordercolour' ) => 'black',
           'absolutey' => 1
           });

           $self->push($t);


           # Vertical lines across all species                                                                                             
           if ($register_line) {
            # This is the end of the box                                                                                                                                
              if( ($start == $box_start) || (($start == 0) && ($box_start == 1)) ) {
		  if(($start == 0) || ($start == 1)) { 
                    $self->join_tag($t, "ruler_$start", 0, 0 , 'red');
                  } else  {
     	            $self->join_tag($t, "ruler_$start", 0, 0 , $start % $major_unit ? 'grey90' : 'grey80');
		  }
      
	      } elsif (($box_end == $global_reg_end) && !(($box_end + 1) % $minor_unit)) {
         
		  $self->join_tag($t, "ruler_$end", 1, 0 ,($global_reg_end + 1) % $major_unit ? 'grey90' : 'grey80');    
	      }
	   }
           

           my $diff = $global_reg_end - $box_start;
           my $mult = $minor_unit * 3;
    
           # Draw the major unit tick                                                                                                                             
           unless( ($box_start % $major_unit) && (($start != 0) && ($box_start != 1)) ) {
             
             unless (($x_addition == 0) && ($diff < $mult)) {
                $self->push($self->Rect({
                'x'         => $box_start - $global_start + $x_addition,
                'y'         => $y,
                'width'     => 0,
                'height'    => 5,
                'colour'    => 'black',
                'absolutey' => 1
	         }));
             }  #unless (($x_addition == 0) && ($diff < $mult)) 

           my $label = $minor_unit < 1000 ? $self->commify($box_start * $contig_strand): $self->bp_to_nearest_unit($box_start * $contig_strand, 2);
           my @res = $self->get_text_width(($box_start - $last_text_x) * $pix_per_bp * 1.5, $label, '', 'font' => $fontname, 'ptsize' => $fontsize);
        
	   if(($label eq '0') || ($label=~/^1( |$)/)) {
	       $label = "0 bp";
           }       
           if(!$res[3]) {
               $res[3] = $prev_height || 10;
           } 

           $prev_height = $res[3]; 
   
           unless (($x_addition == 0) && ($diff < $mult)) {
           #Label with coordinate value 
            #  if ($res[0]) {
	         $self->push($self->Text({
                 'x'         => $box_start - $global_start + $x_addition,
                 'y'         => defined $y ? $y - $res[3] - 1 : 5,     
                 'height'    => $res[3],
                 'font'      => $fontname,
                 'ptsize'    => $fontsize,
                 'halign'    => 'left',
                 'colour'    => $feature_colour,
                 'text'      => $label,
                 'absolutey' => 1
	         }));
            #  }

	   } #unless (($x_addition == 0) && ($diff < $mult))

          $last_text_x = $box_start;
    } # unless 
   
    $last_start = $start;
    $start += $minor_unit;

    if ((($start>$global_reg_end) && ($global_reg_end!=$global_end)) || (($last_start < 0) && ($start >= 0))) {
        $x_addition =  $global_start < 0 ? 0 - $global_start : $global_reg_end - $global_start + 1;
	$global_reg_end = $global_end;
        $global_start = 1;
        $start = floor($global_start / $minor_unit) * $minor_unit;
        $last_text_x = 0;
    }

    $prev_box_start = $box_start;
  
  } # end while
  } else {  
  while ($start <= $global_end) { 

    my $end       = $start + $minor_unit - 1;
    my $box_start = $start < $global_start ? $global_start : $start;
    my $box_end   = $end   > $global_end   ? $global_end   : $end;
 
    $filled = 1 - $filled;
    
    # Draw the glyph for this box
    my $t = $self->Rect({
      'x'         => $box_start - $global_start, 
      'y'         => $y,
      'width'     => abs($box_end - $box_start + 1),
      'height'    => 3,
      ( $filled == 1 ? 'colour' : 'bordercolour' ) => 'black',
      'absolutey' => 1
    });

    $self->push($t);
    
    # Vertical lines across all species
    if ($register_line) {
      # This is the end of the box
      if ($start == $box_start) {
        $self->join_tag($t, "ruler_$start", 0, 0 , $start % $major_unit ? 'grey90' : 'grey80');
      } elsif (($box_end == $global_end) && !(($box_end + 1) % $minor_unit)) {
        $self->join_tag($t, "ruler_$end", 1, 0 ,($global_end + 1) % $major_unit ? 'grey90' : 'grey80');
      }
    }
    
    # Draw the major unit tick 
    unless ($box_start % $major_unit) {
      $self->push($self->Rect({
        'x'         => $box_start - $global_start,
        'y'         => $y, 
        'width'     => 0,
        'height'    => 5,
        'colour'    => 'black',
        'absolutey' => 1
      }));
      
      #my $label = $minor_unit < 250 ? $self->commify($box_start * $contig_strand) : $self->bp_to_nearest_unit($box_start * $contig_strand, 2); # FIXME - commify?!
      #my $label = $self->bp_to_nearest_unit($box_start * $contig_strand, 2);
      my $label = $minor_unit < 1000 ? $self->commify($box_start * $contig_strand): $self->bp_to_nearest_unit($box_start * $contig_strand, 2);
      
      my @res = $self->get_text_width(($box_start - $last_text_x) * $pix_per_bp * 1.5, $label, '', 'font' => $fontname, 'ptsize' => $fontsize);

      if ($res[0]) {
        $self->push($self->Text({
          'x'         => $box_start - $global_start,
          'y'         => defined $y ? $y - $res[3] - 1 : 5,
          'height'    => $res[3],
          'font'      => $fontname,
          'ptsize'    => $fontsize,
          'halign'    => 'left',
          'colour'    => $feature_colour,
          'text'      => $label,
          'absolutey' => 1
        }));
        
        $last_text_x = $box_start;
      }
    }
  
    $start += $minor_unit;

  }  #end while 
  }  #end else 
  
  # Draw the major unit tick 
  unless (($global_end + 1) % $major_unit) {
    $self->push($self->Rect({
      'x'         => $global_end - $global_start + 1,
      'y'         => $y,
      'width'     => 0,
      'height'    => 5,
      'colour'    => 'black',
      'absolutey' => 1
    }));
  }
}

sub bp_to_nearest_unit {
  my ($self, $bp, $dp) = @_;
  
  $dp = 1 unless defined $dp;
   
  my @units = qw( bp Kb Mb Gb Tb );
  my $power = int((length(abs $bp) - 1) / 3);
  
  my $unit = $units[$power];

  my $value = int($bp / (10 ** ($power * 3)));
    
  $value = sprintf "%.${dp}f", $bp / (10 ** ($power * 3)) if $unit ne 'bp';      

  return "$value $unit";
}


1;
