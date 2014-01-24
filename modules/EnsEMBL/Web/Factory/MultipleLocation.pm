package EnsEMBL::Web::Factory::MultipleLocation;

use strict;
use warnings;

use POSIX qw(floor);
use Data::Dumper;

sub createObjects {
    my $self = shift;

    $self->SUPER::createObjects;

    my $object = $self->object;
  
    return unless $object;
  
    # Redirect if we need to generate a new url
    return if $self->generate_url($object->slice);

    my $hub       = $self->hub;
    my @slices;
    my $gene = 0;
    my $action_id = $self->param('id');
    my $invalid = 0;
    my $chr_flag;

    my %inputs = (
	0 => {
        s => $self->species,
        r => $self->param('r'),
        g => $self->param('g')
      }
    );

    foreach ($self->param) {
	$inputs{$2}->{$1} = $self->param($_) if /^([gr])(\d+)$/;
	($inputs{$1}->{'s'}, $inputs{$1}->{'chr'}) = split '--', $self->param($_) if /^s(\d+)$/;
	$chr_flag = 1 if $inputs{$1} && $inputs{$1}->{'chr'};
    }

    # Strip bad parameters (r/g without s)                                                                                                                       
    foreach my $id (grep !$inputs{$_}->{'s'}, keys %inputs) {
       $self->delete_param("$_$id") for keys %{$inputs{$id}};
       $invalid = 1;
    }

    $inputs{$action_id}->{'action'} = $self->param('action') if $inputs{$action_id};
    # If we had bad parameters, redirect to remove them from the url.                                                                                                      

    # If we came in on an a gene, redirect so that we use the location in the url instead.                
    return $self->problem('redirect', $hub->url($hub->multi_params)) if $invalid || $self->input_genes(\%inputs) || $self->change_all_locations(\%inputs);

    foreach (sort { $a <=> $b } keys %inputs) {
	my $species = $inputs{$_}->{'s'};
	my $r       = $inputs{$_}->{'r'};

	next unless $species && $r;

	$self->__set_species($species);

	my ($seq_region_name, $s, $e, $strand) = $r =~ /^([^:]+):(-?\w+\.?\w*)-(-?\w+\.?\w*)(?::(-?\d+))?/;

	$s = 1 if $s < 1;

	$inputs{$_}->{'chr'} ||= $seq_region_name if $chr_flag;

	my $action = $inputs{$_}->{'action'};
	my $chr    = $inputs{$_}->{'chr'} || $seq_region_name;
	my $slice;

	my ($ln, $lnsl);

        #when s is greater than e, the total length is needed to calculate the subtraction 
	foreach my $system (@{$self->__coord_systems}) {
	    eval { $lnsl = $self->slice_adaptor->fetch_by_region($system->name, $chr, $s, $e, $strand); };
	    next if $@;

	    if ($lnsl) {
		$ln  = $lnsl->seq_region_length;
		last;
	    }
	}

	my $dif = $e - $s;
        my $half_ln_1 = (3*$s + $e)/4;
        my $half_ln_2 = (3*$e + $s)/4;
        my $double_ln_1 = (3*$s - $e)/2;      
        my $double_ln_2 = (3*$e - $s)/2;
	if ($lnsl) {
	    if(($lnsl->is_circular) && ($s > $e)) {
		$dif = $ln - $s + $e;

                my $cps = $s + ($dif/2);

                $half_ln_1 = $cps - ($dif/4);
                $half_ln_2 = $cps + ($dif/4);
                $half_ln_1 = $half_ln_1 < 0 ? $ln + $half_ln_1 : $half_ln_1;
                $half_ln_2 = $half_ln_2 > $ln ? $half_ln_2 - $ln : $half_ln_2;

		$double_ln_1 = $cps - $dif;
		$double_ln_2 = $cps + $dif;
                $double_ln_1 = $double_ln_1 < 0 ? $ln + $double_ln_1 : $double_ln_1;
                $double_ln_2 = $double_ln_2 > $ln ? $double_ln_2 - $ln : $double_ln_2;
	    }
	}

	my $modifiers = {
	    in      => sub { ($s, $e) = ($half_ln_1, $half_ln_2) },           # Half the length     
	    out     => sub { ($s, $e) = ($double_ln_1, $double_ln_2) },       # Double the length
	    left    => sub { ($s, $e) = ($s - $dif/10, $e - $dif/10) },       # Shift left by length/10                                              
	    left2   => sub { ($s, $e) = ($s - $dif/2,  $e - $dif/2) },        # Shift left by length/2                                   
	    right   => sub { ($s, $e) = ($s + $dif/10, $e + $dif/10) },       # Shift right by length/10                                 
	    right2  => sub { ($s, $e) = ($s + $dif/2,  $e + $dif/2) },        # Shift right by length/2                                                   
	    flip    => sub { ($strand ||= 1) *= -1 },
	    realign => sub { $self->realign(\%inputs, $_) },
	    primary => sub { $self->change_primary_species(\%inputs, $_) }
	};

        # We are modifying the url - redirect.                                                                                                  
        if ($action && exists $modifiers->{$action}) {
	    $modifiers->{$action}();
            $self->check_slice_exists($_, $chr, $s, $e, $strand);
	    return $self->problem('redirect', $hub->url($hub->multi_params));
	}

	eval { $slice = $self->slice_adaptor->fetch_by_region(undef, $chr, $s, $e, $strand); };
	next if $@;
   
        push @slices, {
          slice      => $slice,
          species    => $species,
          target     => $chr,
          name       => $slice->seq_region_name,
          short_name => $object->chr_short_name($slice, $species),
          start      => $slice->start,
          end        => $slice->end,
          strand     => $slice->strand,
          length     => $slice->seq_region_length
        };
    }

    $object->__data->{'_multi_locations'} = \@slices;
}

sub best_guess {
    my ($self, $slice, $id, $species, $seq_region_name) = @_;

    my $width = $slice->length;
    my $production_species = $self->species_defs->get_config($species, 'SPECIES_PRODUCTION_NAME');

    foreach my $method (qw( BLASTZ_NET LASTZ_NET TRANSLATED_BLAT TRANSLATED_BLAT_NET BLASTZ_RAW BLASTZ_CHAIN )) {
	my ($seq_region, $cp, $strand, $st, $en, $start, $end);

	eval {
	    ($seq_region, $cp, $strand, $st, $en, $start, $end) = $self->dna_align_feature_adaptor->interpolate_best_location($slice, $production_species, $method, $seq_region_name);
	};

	if ($seq_region) {
	    unless ($start && $end) {
		$start = floor($cp - ($width-1)/2);
		$end   = floor($cp + ($width-1)/2);
	    }

	    my $start = floor($cp - ($width-1)/2);
	    my $end   = floor($cp + ($width-1)/2);

	    $self->__set_species($species);

	    return 1 if $self->check_slice_exists($id, $seq_region, $start, $end, $strand);
	}
    }
}

sub check_slice_exists {
    my ($self, $id, $chr, $start, $end, $strand) = @_;

    if (defined $start) {
	$start = floor($start);

	$end = $start unless defined $end;
	$end = floor($end);
        my ($orig_start, $orig_end) = ($start, $end);
	$end = 1 if $end < 1;

        # Truncate slice to start of seq region                                                                                                                                                     
	if ($start < 1) {
	    $end += abs($start) + 1;
	    $start = 1;
	}

        # ($start, $end) = ($end, $start) if $start > $end;

	$strand ||= 1;

	foreach my $system (@{$self->__coord_systems}) {
	    my $slice;

	    eval { $slice = $self->slice_adaptor->fetch_by_region($system->name, $chr, $start, $end, $strand); };
	    next if $@;

	    if ($slice) {
                if($slice->is_circular) {
                   
                    while ($orig_end < 1) {  $orig_end   = $slice->seq_region_length + $orig_end; }
                    while ($orig_start < 1) { $orig_start = $slice->seq_region_length + $orig_start; }
                    while ($orig_start > $slice->seq_region_length) { $orig_start = $orig_start - $slice->seq_region_length; }
                    while ($orig_end  > $slice->seq_region_length) {  $orig_end   = $orig_end   - $slice->seq_region_length; }
                    ($start, $end) = ($orig_start, $orig_end);
		    $slice = $self->slice_adaptor->fetch_by_region($system->name, $chr, $start, $end, $strand);

                }  else  {

  	           ($start, $end) = ($end, $start) if $start > $end;
		   if ($start > $slice->seq_region_length || $end > $slice->seq_region_length) {
		      ($start, $end) = ($slice->seq_region_length - $slice->length + 1, $slice->seq_region_length);
		      $start = 1 if $start < 1;

		      $slice = $self->slice_adaptor->fetch_by_region($system->name, $chr, $start, $end, $strand);
                                       
		   }
	        }

                #warn 'Slice: ' . $slice->seq_region_length . ' NEW start: ' . $orig_start . ' NEW end: ' . $orig_end . '  circ: ' . $slice->is_circular;
              
		$self->param('r' . ($id || ''), "$chr:$start-$end:$strand"); # Set the r parameter for use in the redirect
		return 1;
	    }
	}
    }

    return 0;
}

sub change_all_locations {
    my ($self, $inputs) = @_;

    if ($self->param('multi_action') eq 'all') {
	my $all_s = $self->param('all_s');
	my $all_w = $self->param('all_w');

	foreach (keys %$inputs) {
	    my ($seq_region_name, $s, $e, $strand) = $inputs->{$_}->{'r'} =~ /^([^:]+):(-?\w+\.?\w*)-(-?\w+\.?\w*)(?::(-?\d+))?/;

	    $self->__set_species($inputs->{$_}->{'s'});

	    my $max = $self->slice_adaptor->fetch_by_region(undef, $seq_region_name, $s, $e, $strand)->seq_region_length;
            my $circ = $self->slice_adaptor->fetch_by_region(undef, $seq_region_name, $s, $e, $strand)->is_circular;

            #warn 'INITIAL: max: ' . $max . ' s - e : '  . $s . ' - ' . $e. ' all_w: ' . $all_w;
	    if ($all_s) {
                if($circ) { 
		   $s += $all_s;
		   $e += $all_s;
                   $s = $s > $max ? $s - $max : $s; 
		   $e = $e > $max ? $e - $max : $e;
                   $s = $s < 0 ? $s + $max : $s;
		   $e = $e < 0 ? $e + $max : $e;
                } else {
    		   $s += $all_s;
		   $e += $all_s;
	        }
	    } else {
                if ($circ) {
 
     	          
                  my $c;
                  if ($s > $e) {
                    $c = $s + int(($max - $s + $e) / 2);
		  }  else {
		    $c =  int(($s + $e) / 2);
                  }
                  #warn 'MIDDLE POINT:  c: ' . $c. ' all_w: ' . $all_w; 
                  ($s, $e) = ($c - int($all_w/2) + 1, $c + int($all_w/2));
                  $s = $s < 0 ? $max + $s : $s;
                  $s = $s > $max ? $s - $max : $s;
                  $e = $e > $max ? $e - $max : $e; 
                } else { 
		  my $c = int(($s + $e) / 2);
		  ($s, $e) = ($c - int($all_w/2) + 1, $c + int($all_w/2));
	        }
       	    }           

            
            $s = 1 if $s == 0;
            $e = 1 if $e == 0;
 
            #in case it is non-circ: 
	    ($s, $e) = (1, $e - $s || 1) if $s < 1;
	    ($s, $e) = ($max - ($e - $s), $max) if $e > $max;
	    $s = 1 if $s < 1;

            #warn 'AFTER: max: ' . $max . ' s - e : '  . $s . ' - ' . $e;

	    $self->param($_ ? "r$_" : 'r', "$seq_region_name:$s-$e" . ($strand ? ":$strand" : ''));
	}

	return 1;
    }
}


1;
