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

package Bio::EnsEMBL::GlyphSet::codonseq;

# Bug fix: Translated sequence track in detailed view wasn't working
sub features {
  my ($self) = @_;

  my $seq    = $self->{'container'}->subseq(-2, $self->{'container'}->length + 4);
  my $strand = $self->strand;

  #Added for the fix BOF  
  if ( ($self->{'container'}->is_circular) && (  (($self->{'container'}->start - 2) < 1) || (($self->{'container'}->length + 4) > $self->{'container'}->seq_region_length) ) ) {
    my ($seq1, $seq2); 
    if  (($self->{'container'}->start - 2) < 1) {
      $seq1 = $self->{'container'}->subseq( ($self->{'container'}->seq_region_length + ($self->{'container'}->start - 2 - 1)), $self->{'container'}->seq_region_length);
      $seq2 =  $self->{'container'}->subseq( 1, $self->{'container'}->length + 4);    
    } 
    if (($self->{'container'}->length + 4) >$self->{'container'}->seq_region_length) {
      $seq1 ||= $self->{'container'}->subseq(-2, $self->{'container'}->seq_region_length);
      $seq2 =   $self->{'container'}->subseq(1, $self->{'container'}->length + 4); 
    }
    $seq = $strand > 0 ? "$seq1$seq2" : "$seq2$seq1";
    
  }
  #Added for the fix EOF

  my @features;
  
  foreach my $phase (0..2) {
    my $string = substr $seq, $phase, 3 * int((length($seq) - $phase)/3);

    if ($strand == -1) { # Reverse complement sequence
       $string = reverse $string;
       $string =~ tr/AGCTagct/TCGAtcga/;
    }
    
    my $bioseq = new Bio::Seq(-seq => $string, -moltype => 'dna');
    
    $string = $bioseq->translate->seq;
    $string = reverse $string if $strand == -1;
    
    my $start = $phase - 5;

    my $test_s = $start;
 
    push @features, map {
      Bio::EnsEMBL::Feature->new(
        -start => $start+=3,
        -end   => $start+2,
        -seqname => $_,
        -strand  => $strand
      )
    } split //, $string;
  }
  
  return \@features;
}

sub title {
  my ($self, $f) = @_;
  my $start = $self->{'container'}->start - 1;
  return sprintf '%s; Location: %s:%s-%s', $f->seqname, $self->{'container'}->seq_region_name, $start + $f->start, $start + $f->end;
}

1;
