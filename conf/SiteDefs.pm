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
    $SiteDefs::ENSEMBL_PORT           = 8004;

    $SiteDefs::ENSEMBL_SERVERNAME     = 'fungi.ensembl.org';

    $SiteDefs::ENSEMBL_PRIMARY_SPECIES  = 'Saccharomyces_cerevisiae';
    $SiteDefs::ENSEMBL_SECONDARY_SPECIES  = 'Schizosaccharomyces_pombe';
    
    $SiteDefs::__species_aliases{ 'Saccharomyces_cerevisiae' } = [qw(sc scer yeast saccharomyces S_cerevisiae S_cerevisiae_ATCC_204508)];
    $SiteDefs::__species_aliases{ 'Schizosaccharomyces_pombe' } = [qw(sp pombe S_pombe)];

    $SiteDefs::__species_aliases{ 'Aspergillus_nidulans' } = [qw(as )];
    $SiteDefs::__species_aliases{ 'Aspergillus_niger' } = [qw(an A_niger)];
    $SiteDefs::__species_aliases{ 'Aspergillus_fumigatus' } = [qw(af A_fumigatus)];
    $SiteDefs::__species_aliases{ 'Aspergillus_oryzae' } = [qw(ao A_oryzae)];
    $SiteDefs::__species_aliases{ 'Aspergillus_terreus' } = [qw(at A_terreus)];
    $SiteDefs::__species_aliases{ 'Aspergillus_flavus' } = [qw(av A_flavus)];
    $SiteDefs::__species_aliases{ 'Neosartorya_fischeri' } = [qw(nf N_fischeri)];
    $SiteDefs::__species_aliases{ 'Aspergillus_clavatus' } = [qw(ac A_clavatus)];
    
    $SiteDefs::__species_aliases{ 'Aspergillus_fumigatusa1163' } = [qw(af A_fumigatus_a1163)];
    $SiteDefs::__species_aliases{ 'Verticillium_dahliae'} = [qw(Verticillium_dahliae)];
    $SiteDefs::__species_aliases{ 'Schizosaccharomyces_octosporus' } = [qw(Schizosaccharomyces_octosporus)];
    $SiteDefs::__species_aliases{ 'Schizosaccharomyces_cryophilus' } = [qw(Schizosaccharomyces_cryophilus)];
    $SiteDefs::__species_aliases{ 'Blumeria_graminis' } = [qw(Blumeria_graminis)];
    $SiteDefs::__species_aliases{ 'Microbotryum_violaceum' } = [qw(Microbotryum_violaceum)];

    $SiteDefs::__species_aliases{ 'Neurospora_crassa' } = [qw(nc N_crassa)];

#    $SiteDefs::__species_aliases{ 'Puccinia_graministritici' } = [qw(pg P_graministritici)];

    $SiteDefs::__species_aliases{ 'Fusarium_oxysporum' } = [qw(fo F_oxysporum)];
            
    $SiteDefs::__species_aliases{ 'Ustilago_maydis' } = [qw(um U_maydis)];
    $SiteDefs::__species_aliases{ 'Puccinia_triticina' } = [qw(tc T_triticina)];

    $SiteDefs::__species_aliases{ 'Tuber_melanosporum' } = [qw(tm T_melanosporum)];
    $SiteDefs::__species_aliases{ 'Melampsora_laricipopulina' } = [qw(ml)];
    $SiteDefs::__species_aliases{ 'Phaeosphaeria_nodorum' } = [qw(pn P_nodorum)];

    $SiteDefs::__species_aliases{ 'Ashbya_gossypii' } = [qw(ag A_gossypii)];
# Release 13    
    $SiteDefs::__species_aliases{ 'Gaeumannomyces_graminis' } = [qw(gg G_graminis)];
    $SiteDefs::__species_aliases{ 'Magnaporthe_oryzae' } = [qw(mo)];
    $SiteDefs::__species_aliases{ 'Magnaporthe_poae' } = [qw(mp)];
 
    $SiteDefs::__species_aliases{ 'Botrytis_cinerea' } = [qw(bc)];
    $SiteDefs::__species_aliases{ 'Puccinia_graminis' } = [qw(pg)];
    $SiteDefs::__species_aliases{ 'Schizosaccharomyces_japonicus'} = [qw(sj)];
    $SiteDefs::__species_aliases{ 'Sclerotinia_sclerotiorum'} = [qw(ss)];
    $SiteDefs::__species_aliases{ 'Leptosphaeria_maculans'} = [qw(lm)];
    $SiteDefs::__species_aliases{ 'Trichoderma_virens'} = [qw(tv)];
    $SiteDefs::__species_aliases{ 'Colletotrichum_graminicola'} = [qw(cg)];
    $SiteDefs::__species_aliases{ 'Komagataella_pastoris'} = [qw(kp)];
    $SiteDefs::__species_aliases{ 'Pyrenophora_teres'} = [qw(pte)];
    $SiteDefs::__species_aliases{ 'Pyrenophora_triticirepentis'} = [qw(ptr)];
    $SiteDefs::__species_aliases{ 'Sporisorium_reilianum'} = [qw(sr)];
    $SiteDefs::__species_aliases{ 'Zymoseptoria_tritici'} = [qw(zt)];
    $SiteDefs::__species_aliases{ 'Yarrowia_lipolytica'} = [qw(yl)];
    $SiteDefs::__species_aliases{ 'Trichoderma_reesei'} = [qw(tr)];
    $SiteDefs::__species_aliases{ 'Cryptococcus_neoformans'} = [qw(cn)];
# Release 23
    #$SiteDefs::__species_aliases{ 'Cladosporium_fulvum' } = [qw(cf)];  ## delayed
    $SiteDefs::__species_aliases{ 'Colletotrichum_gloeosporioides' } = [qw(cg)];
    $SiteDefs::__species_aliases{ 'Colletotrichum_higginsianum' } = [qw(ch)];
    $SiteDefs::__species_aliases{ 'Colletotrichum_orbiculare' } = [qw(co)];
    $SiteDefs::__species_aliases{ 'Dothistroma_septosporum' } = [qw(ds)];
    $SiteDefs::__species_aliases{ 'Fusarium_fujikuroi' } = [qw(ff)];
    $SiteDefs::__species_aliases{ 'Fusarium_pseudograminearum' } = [qw(fp)];
    $SiteDefs::__species_aliases{ 'Puccinia_graminisug99' } = [qw(pgug99)];
# Release 25
    $SiteDefs::__species_aliases{ 'Verticillium_dahliaejr2' } = [qw(Verticillium_dahliaejr2)];
    $SiteDefs::__species_aliases{ 'Fusarium_verticillioides' } = [qw(Fusarium_verticillioides)];
    $SiteDefs::__species_aliases{ 'Fusarium_solani' } = [qw(Fusarium_solani)];
    $SiteDefs::__species_aliases{ 'Fusarium_graminearum' } = [qw(Fusarium_graminearum)];


    $SiteDefs::SITE_NAME = 'Ensembl Fungi';
    $SiteDefs::ENSEMBL_SITETYPE = 'Ensembl Fungi';
    $SiteDefs::SITE_FTP= 'ftp://ftp.ensemblgenomes.org/pub/fungi';

    @SiteDefs::ENSEMBL_PERL_DIRS    = (
                                           $SiteDefs::ENSEMBL_WEBROOT.'/perl',
                                           $SiteDefs::ENSEMBL_SERVERROOT.'/eg-web-common/perl',
                                           $SiteDefs::ENSEMBL_SERVERROOT.'/eg-web-fungi/perl',
                                       );

    push @SiteDefs::ENSEMBL_HTDOCS_DIRS,  $SiteDefs::ENSEMBL_SERVERROOT.'/../biomarts/fungi/biomart-perl/htdocs';

    $SiteDefs::DOCSEARCH_INDEX_DIR = $SiteDefs::ENSEMBL_SERVERROOT.'/eg-web-fungi/data/docsearch';

    $SiteDefs::ENA_COLLECTION_ID = 221;
    $SiteDefs::ENA_SAMPLE_SEQ = "TTATGTCGATGACATACTATTCAGAGAATGTTCTTTCCCGACTAGGAAGGGAAGTCGGAGTTATTCCGTTGGAGACCACAACCCCAGGCTCTCCCCACAGTCCACAAAAACCCCATTCGCAAAGCCATGGAGAGGTGGGCACAGACCGTCTGAACCACTCGGTCGAGGTTCACCAATCAATTTCATTCTCTCAATGTTCCTGGTCCCTACCGCGGGAATTTAGCCGGGCAGCCCGTCTAAATGACCCCAAACAACCGTCGGATTGCCGATGATGGGCTTATCATCGGCGTCGCGCGGCGATATATCCCGTCCGTTATCCCCAGTCTTCAGGTTGTCGCGGCCGACTGTGGGGTTTTTTACACTCCGTTCATCGTCACTCTTGCCAGAAACGTAACCTCATTCGTCTGGATCAGGTCTCCATTGCTCCCTCCCGGCTTTGATTCGGCTCGTCAGTGAGGTCGATGTGCAGTCCTCAGGCCAGCATAAGTAGTCCTGTAACCCCACACGTACCCTCACTTTTTTTCCCCCCTTGCGAGCGAGCTTTATTGTAGTGGCAGATTGAGCTTCTAATATCTTCATTGTTGATACCCAACGCCCATCATGAGTGATCAAATATCCTCGTGGAATGTCGTCCACAAGTTCGAAAAGCGCGGCCTTCTCATCGCCATTAACTGCGTGGCTGCCCTGTCAATCCTTTTCTTTGGATATGACCAGGGTATGATGTCTGGAGTGAACAACTCCAAGGACTATATCGATCTCATGGGGTTTGGCTATACGGAGATGAAGGATGGCCACCCTTCCCCCGTGGTGACCAACAGTCTGCTCCAAGGCGGCATCGTCAGTGTCTATTATTTAGGTACGCTCTTCGGTGCGCTGGTTGGCGGTTGGACTGGAGACAAGGTTGGTAGAATCAAGACGATTGCCTTCGGCTCAGTCTGGGCCATGTTTGGGGCCGCTCTACAGTGCTCAGCCCAGAACCACGACTGGATGATCTGCGGTTAGCCGTCTTGCCCGATCCCTGTGTTTTTGTGACTTTTCTAGCTGACTTAGGTAGCGCGATTTATAAACGGAATTGGAACCGGAATACTCAACGCGATTGTTCCCGTATGGGCGACCGAGACTGCAGAACACACGAGTCGTGGCCAGTTCATTGCAATCGAGTTCACACTGAACATCTTCGGTGTCGTGCTCGCATATTGGCTTGAATTGTAAGCAATAGAAGAAGCCAACTTGGACCATGCACTAACGATCATACAGCGGCCTGTCTTTCATCGATAACGGCGCATCGCCCTTCCGCTGGCGCTTCCCGATCGCGTTCCAAATCATCTTCTTGCTCGTTCTATTCGCCGCCGTTTGGTTCTTCCCGGAATCCCCACGTTGGTTGGTGAAGGTTGGTCGGGAGCAGGAGGCTCGGTATATTCTGGGTAGGCTGCGTGGCAGCAGCGGTGAAGATGCCATCCGGGCCGAGGCCGAGTTCCAGGATATTCTCAGCGTCGCGGAGGCAGAGAGGTCCATGGGCCACAGCACGTCTTACCTGGCTATGCTTTTCGGATACAAGACCGGGAAGTTGCATCTTGGCCGCCGGGTTCAACTTGTGGTATGGCTACAGATCATGCAGGAGTGGGTTGGTATTGCCGGTGTTGACTGTTTGTACGTCGCCCTTGAGATAATGTCGGGCCCAGGCTAATGGTTCTGCAGATGCCCCGACTATTTTCAGCATTGCAGGATTCGATTCCATGAAGAGTCAATGGATCAGCGGTTTAAACAACGTCTTTTACATGGTATGTCGTCCTTCTCTGGGCTTGGTACAGGCACATGCTAACAGAACAGTTTGCTACTATGATCTGTGTCTTTACTCTCGACCGAATCGGCCGTCGGTGGACTTTGTACTGGGGAGCTGCAGCCCAAGGAATCGCCATGTTCCTTGCTGGGGGTTTCTCACGTGTTTCGATCGACGCACGAGATGCGGGCAACATGGCGCGAGCTGAATCATTCGGTGCTGCTGCAGCGTCCATGGTTTTTGTATTCACCGCGGTCTTCGGAGCCACCTGGCTCACAGTGCCTTGGATCTATCCTGCGGAGATTTATCCATTAGCCGTCCGTGCAAAGGGTAATGCCTGGGGTGTTGTCGGCTGGAGTATTGGAAACGGATGGTTGGTGAGTGGTCGTGACCAAATTACAAATTTCTAAGCACGCACTAAACTATAGCTCTACAGACCCTCCTCTGCCCTGTGATGTTTGAAGCCATCGGGGAGAAGACCCTCTACGTATTCGCTGCCAGCAACGTGATCGCGATTCCAATGGTCTGGGCATTATACCCAGAGAGTAACCAGCGGACGCTAGAGGATATGGACCTGCTATTCGCTGCTGATACGCCTTGGGTGTGGGATGCAGAGAAGACATTTGCCCGCCTCAAGGCTGAGAACCCCGGGTTTATTGAGACCGCCGCGCGGAAGAATAGCGTGCTGGATGAGGAGGCTGCCAAGTCGGTGACTCTGGCGCATCGTGAAACTGTCGCTTGACAAGTTAAGATGAGATACCTTGTGATAGAGCAGGTGTAATTCAAGATAGCACCTCAAGAGAAATTATTATATAAAAGGCCATAATCGTAATTTGCCTTTGGTTTAGCCCTAGTATAACTAGTTTGATCATTGAGATTGAACTGCCTTCATTCTGCATAGTATGCAGACATAGGACATAGACAAAGCGAGAGTGCCAGAGAGTTCTGTACATGCGCTTACAGGAGGTAGAAGAGGCTTATGCGGGGAAATCCGAGCAATCCCCGCATCACGTTTTACCGGCCGGGCCAGATCGTGGCTAGTGCATTTGTACCAGCCACATACCCAAAACCTCGATACGTGGTGTATCCGGTCCCTAGTTAATCCGGGCCGTTTCCAGCTCCCAACACCAAAAGCACAGCTGGCATTAGTAGTATCACCACCCACGCTATCTCGACTTTCAACCTGCCACTCCTCCCTTTCGATCAATCCTTGTCTTTAGATCTCTCCACGTCCTGTCTACAGTGTTAATTTAGTCATAATTCGCCATCATGTCCGAACAAGTACAGGAATTGCTCAACATCCCTCAGGAGTTCCTTCGCGATGGAATGCAGTTTGTGAACCGCAGTCAGAAGCGTATGCATAGCCTTTTCTCTCTCATTTTATCTGTTTCAACTCCCTGGATCGTGTT";



}

1;
