package EnsEMBL::Web::Object::Location;

## ENSEMBL-2811
## Hack to disable synteny for Aspergillus* 
## It is broken in compara db for EG20,21
## Should be fixed for 22 - if so we can drop this plugin.

use strict;
use warnings;
no warnings 'uninitialized';

use previous qw(availability);

sub availability {
  my $self = shift; 
  if (!$self->{_availability}) {
    $self->PREV::availability;
    $self->{_availability}->{has_synteny} = 0 if $self->hub->species =~ /aspergillus/i;
  }
  return $self->{_availability};
}

1;