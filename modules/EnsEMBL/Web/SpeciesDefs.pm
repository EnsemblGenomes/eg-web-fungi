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

package EnsEMBL::Web::SpeciesDefs;

use strict;
use previous qw(_get_NCBIBLAST_source_file);

## hack for ENSEMBL-4509
## rewrite Botrytis_cinerea.ASM83294v1.dna.toplevel --> Botrytis_cinerea.ASM83294v1.31.dna.toplevel
## as it accidentally got submitted with additional '.31'
sub _get_NCBIBLAST_source_file {
  my $self = shift;
  my $file = $self->PREV::_get_NCBIBLAST_source_file(@_);
  $file =~ s/\.ASM83294v1\./.ASM83294v1.31./;
  return $file;
}
##

1;
