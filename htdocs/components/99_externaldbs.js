Ensembl.LayoutManager = Ensembl.LayoutManager.extend({
  
  externalDbUrls: function () {
    var superUrls = this.base();
    var myUrls = {
   "Schizosaccharomyces_pombe" : {
      "Pombase" : "http://genomebrowser.pombase.org/Schizosaccharomyces_pombe/Location/View?r=I%3A###START###-###END###"
   },
   "Saccharomyces_cerevisiae" : {
      "YeastGenome" : "http://www.yeastgenome.org/cgi-bin/gbrowse/scgenome/?name=Chr###CHR###%3A###START###..###END###"
   }
}
;
    var merged = $.extend(superUrls, myUrls);
    return merged;
  }
});
