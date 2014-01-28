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

package Bio::EnsEMBL::Slice;

=head2 is_circular
   Arg        : none
   Example    : my $circular = $slice->is_circular
   Description: Returns 1 if slice is a circular region
   Returntype : int
   Caller     : general
   Status     : At Risk
 
=cut
 
sub is_circular {
  my ($self) = @_;
 
  if(!defined($self->{'circular'})){
    my @attrs = grep { $_ } @{$self->get_all_Attributes('circular_seq')};
    $self->{'circular'} = @attrs ? 1 : 0;
  }
 
  return $self->{'circular'};

}

1;
