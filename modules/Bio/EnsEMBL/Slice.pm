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
