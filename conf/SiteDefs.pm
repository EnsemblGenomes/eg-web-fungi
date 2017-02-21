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

package EG::Fungi::SiteDefs;
use strict;
sub update_conf {

    $SiteDefs::EG_DIVISION                = 'fungi';
    $SiteDefs::SITE_NAME                  = 'Ensembl Fungi';
    $SiteDefs::ENSEMBL_SITETYPE           = 'Ensembl Fungi';
    $SiteDefs::SITE_FTP                   = 'ftp://ftp.ensemblgenomes.org/pub/fungi';
    $SiteDefs::ENSEMBL_PORT               = 8004;
    $SiteDefs::ENSEMBL_SERVERNAME         = 'fungi.ensembl.org';
    $SiteDefs::ENSEMBL_PRIMARY_SPECIES    = 'Saccharomyces_cerevisiae';
    $SiteDefs::ENSEMBL_SECONDARY_SPECIES  = 'Schizosaccharomyces_pombe';
    $SiteDefs::LARGE_SPECIES_SET          = 1;
    $SiteDefs::ENSEMBL_HMMER_ENABLED      = 1;

    $SiteDefs::ENSEMBL_DATASETS = [
      qw(
        Ashbya_gossypii
        Aspergillus_clavatus
        Aspergillus_flavus
        Aspergillus_fumigatus
        Aspergillus_fumigatusa1163
        Aspergillus_nidulans
        Aspergillus_niger
        Aspergillus_oryzae
        Aspergillus_terreus
        Blumeria_graminis
        Botrytis_cinerea
        Colletotrichum_gloeosporioides
        Colletotrichum_graminicola
        Colletotrichum_higginsianum
        Colletotrichum_orbiculare
        Cryptococcus_neoformans
        Dothistroma_septosporum
	Fusarium_culmorum
        Fusarium_fujikuroi
        Fusarium_graminearum
        Fusarium_oxysporum
        Fusarium_pseudograminearum
        Fusarium_solani
        Fusarium_verticillioides
        Gaeumannomyces_graminis
        Komagataella_pastoris
        Leptosphaeria_maculans
        Magnaporthe_oryzae
        Magnaporthe_poae
        Melampsora_laricipopulina
        Microbotryum_violaceum
        Neosartorya_fischeri
        Neurospora_crassa
        Phaeosphaeria_nodorum
        Puccinia_graminis
        Puccinia_graminisug99
	Puccinia_striiformis
        Puccinia_triticina
        Pyrenophora_teres
        Pyrenophora_triticirepentis
        Saccharomyces_cerevisiae
        Schizosaccharomyces_cryophilus
        Schizosaccharomyces_japonicus
        Schizosaccharomyces_octosporus
        Schizosaccharomyces_pombe
        Sclerotinia_sclerotiorum
        Sporisorium_reilianum
        Trichoderma_reesei
        Trichoderma_virens
        Tuber_melanosporum
        Ustilago_maydis
        Verticillium_dahliae
        Verticillium_dahliaejr2
        Yarrowia_lipolytica
        Zymoseptoria_tritici
      ),
      # collections
      qw(
        Fungi_ascomycota1
        Fungi_ascomycota2
        Fungi_ascomycota3
        Fungi_basidiomycota1
        Fungi_blastocladiomycota1
        Fungi_chytridiomycota1
        Fungi_entomophthoromycota1
        Fungi_fungiincertaesedis1
        Fungi_glomeromycota1
        Fungi_microsporidia1
        Fungi_rozellomycota1
      )
    ];

    @SiteDefs::ENSEMBL_PERL_DIRS    = (
      $SiteDefs::ENSEMBL_WEBROOT.'/perl',
      $SiteDefs::ENSEMBL_SERVERROOT.'/eg-web-common/perl',
      $SiteDefs::ENSEMBL_SERVERROOT.'/eg-web-fungi/perl',
    );

    push @SiteDefs::ENSEMBL_HTDOCS_DIRS,  $SiteDefs::ENSEMBL_SERVERROOT.'/../biomarts/fungi/biomart-perl/htdocs';

    $SiteDefs::MAX_PROCESS_SIZE = 1000000; # Kill httpd over 1000000KB
}

1;
