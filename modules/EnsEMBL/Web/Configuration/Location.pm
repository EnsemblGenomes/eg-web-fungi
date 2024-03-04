=head1 LICENSE

Copyright [2009-2024] EMBL-European Bioinformatics Institute

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

# $Id: Location.pm,v 1.4 2011-07-01 12:25:01 it2 Exp $ 

package EnsEMBL::Web::Configuration::Location;

sub add_external_browsers {
  my $self         = shift;
  my $hub          = $self->hub;
  my $object       = $self->object;
  my $species_defs = $hub->species_defs;
  
  # Links to external browsers - UCSC, NCBI, etc
  my %browsers = %{$species_defs->EXTERNAL_GENOME_BROWSERS || {}};
  $browsers{'UCSC_DB'} = $species_defs->UCSC_GOLDEN_PATH;
  $browsers{'NCBI_DB'} = $species_defs->NCBI_GOLDEN_PATH;
  
  my ($chr, $start, $end) = $object ? ($object->seq_region_name, int $object->seq_region_start, int $object->seq_region_end) : ();
  my $url;
  
  if ($browsers{'UCSC_DB'}) {
    if ($chr) {
      $url = $hub->get_ExtURL('EGB_UCSC', { UCSC_DB => $browsers{'UCSC_DB'}, CHR => $chr, START => $start, END => $end });
    } else {
      $url = $hub->get_ExtURL('EGB_UCSC', { UCSC_DB => $browsers{'UCSC_DB'}, CHR => 1, START => 1, END => 1000000 });
    }
    
    $self->get_other_browsers_menu->append($self->create_node('UCSC_DB', 'UCSC', [], { availability => 1, url => $url, raw => 1, external => 1 }));
    
    delete $browsers{'UCSC_DB'};
  }
  
  if ($browsers{'NCBI_DB'}) {
    if ($chr) { 
      $url = $hub->get_ExtURL('EGB_NCBI', { NCBI_DB => $browsers{'NCBI_DB'}, CHR => $chr, START => $start, END => $end });
    } else {
      my $taxid = $species_defs->get_config($hub->species, 'TAXONOMY_ID'); 
      $url = "http://www.ncbi.nih.gov/mapview/map_search.cgi?taxid=$taxid";
    }
    
    $self->get_other_browsers_menu->append($self->create_node('NCBI_DB', 'NCBI', [], { availability => 1, url => $url, raw => 1, external => 1 }));
    
    delete $browsers{'NCBI_DB'};
  }

  
  foreach (sort keys %browsers) {
    next unless $browsers{$_};
   
    #mapping needed to match the chrmosome name convention of SGD browser:    
    my $map_chr = {};  
    if ($_ eq 'SGD') {
      my $chrindex = 1;
      foreach my $chrom (@{$species_defs->get_config($hub->species, 'ENSEMBL_CHROMOSOMES') || []}) {    
        $map_chr->{$chrom} = $chrindex < 10 ? '0'.$chrindex : $chrindex;  
        $map_chr->{$chrom} = 'mt'   if $chrom eq 'Mito';
	$map_chr->{$chrom} = $chrom if $chrom eq '2-micron';
        $chrindex++;
      }
      $chr = $map_chr->{$chr};
    }    

    $url = $hub->get_ExtURL($_, { CHR => $chr, START => $start, END => $end });
    $self->get_other_browsers_menu->append($self->create_node($browsers{$_}, $browsers{$_}, [], { availability => 1, url => $url, raw => 1, external => 1 }));
  }
}

1;
