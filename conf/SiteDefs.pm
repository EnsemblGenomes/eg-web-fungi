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
    $SiteDefs::SUBDOMAIN_DIR              = 'fungi';
    $SiteDefs::SITE_NAME                  = 'Ensembl Fungi';
    $SiteDefs::ENSEMBL_SITETYPE           = 'Ensembl Fungi';
    $SiteDefs::SITE_FTP                   = 'ftp://ftp.ensemblgenomes.org/pub/fungi';
    $SiteDefs::ENSEMBL_PORT               = 8004;
    $SiteDefs::ENSEMBL_SERVERNAME         = 'fungi.ensembl.org';
    $SiteDefs::ENSEMBL_PRIMARY_SPECIES    = 'Saccharomyces_cerevisiae';
    $SiteDefs::ENSEMBL_SECONDARY_SPECIES  = 'Schizosaccharomyces_pombe';
    $SiteDefs::LARGE_SPECIES_SET          = 1;
    $SiteDefs::ENSEMBL_HMMER_ENABLED      = 1;

    $SiteDefs::PRODUCTION_NAMES = [
      qw(
        ashbya_gossypii
        aspergillus_clavatus
        aspergillus_flavus
        aspergillus_fumigatus
        aspergillus_fumigatusa1163
        aspergillus_nidulans
        aspergillus_niger
        aspergillus_oryzae
        aspergillus_terreus
        beauveria_bassiana
        blumeria_graminis
        botrytis_cinerea
        colletotrichum_gloeosporioides
        colletotrichum_graminicola
        colletotrichum_higginsianum
        colletotrichum_orbiculare
        cryptococcus_neoformans
        dothistroma_septosporum
        fusarium_culmorum
        fusarium_fujikuroi
        fusarium_graminearum
        fusarium_oxysporum
        fusarium_pseudograminearum
        fusarium_solani
        fusarium_verticillioides
        gaeumannomyces_graminis
        komagataella_pastoris
        leptosphaeria_maculans
        magnaporthe_oryzae
        magnaporthe_poae
        melampsora_laricipopulina
        microbotryum_violaceum
        neosartorya_fischeri
        neurospora_crassa
        phaeosphaeria_nodorum
        puccinia_graminis
        puccinia_graminisug99
        puccinia_striiformis
        puccinia_triticina
        pyrenophora_teres
        pyrenophora_triticirepentis
        saccharomyces_cerevisiae
        schizosaccharomyces_cryophilus
        schizosaccharomyces_japonicus
        schizosaccharomyces_octosporus
        schizosaccharomyces_pombe
        sclerotinia_sclerotiorum
        sporisorium_reilianum
        trichoderma_reesei
        trichoderma_virens
        tuber_melanosporum
        ustilago_maydis
        verticillium_dahliae
        verticillium_dahliaejr2
        yarrowia_lipolytica
        zymoseptoria_tritici
      ),
      # collections
      qw(
        fungi_ascomycota1
        fungi_ascomycota2
        fungi_ascomycota3
        fungi_basidiomycota1
        fungi_blastocladiomycota1
        fungi_chytridiomycota1
        fungi_entomophthoromycota1
        fungi_microsporidia1
        fungi_mucoromycota1
        fungi_rozellomycota1
      )
    ];

    @SiteDefs::ENSEMBL_PERL_DIRS    = (
      $SiteDefs::ENSEMBL_WEBROOT.'/perl',
      $SiteDefs::ENSEMBL_SERVERROOT.'/eg-web-common/perl',
      $SiteDefs::ENSEMBL_SERVERROOT.'/eg-web-fungi/perl',
    );

    push @SiteDefs::ENSEMBL_HTDOCS_DIRS,  $SiteDefs::ENSEMBL_SERVERROOT.'/../biomarts/fungi/biomart-perl/htdocs';

    $SiteDefs::ENSEMBL_MAX_PROCESS_SIZE = 1000000; # Kill httpd over 1000000KB
}

1;
