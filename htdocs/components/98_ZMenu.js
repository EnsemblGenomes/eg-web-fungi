// $Revision: 1.9 $

Ensembl.Panel.ZMenu = Ensembl.Panel.ZMenu.extend({
  constructor: function () {
    this.base.apply(this, arguments);
    
    if (this.drag) {
      var params = this.href.split('|');
      this.midpointChr = parseInt(params[8], 10);
      this.midpointImg = parseInt(params[9], 10);
      this.splitFlag   = parseInt(params[10], 10);  
    }
  },
  
  populateVRegion: function () {
    var start, end, view, menu, caption, tmp, url;
    
    var min = this.start;
    var max = this.end;
    
    var scale = (max - min + 1) / (this.areaCoords.b - this.areaCoords.t);

    // Region select
    if (this.coords.r) {
      view = 'Overview';
      
      start = Math.floor(min + (this.coords.s - this.areaCoords.t) * scale);
      end   = Math.floor(min + (this.coords.s + this.coords.r - this.areaCoords.t) * scale);
    
      if (start > end) {
        tmp = start;
        start = end;
        end = tmp;
      }
      
      if (start < min) {
        start = min;
      }
      
      if (end > max) {
        end = max;
      }
      
      if (end < min) {
        end = min;
      }

      if (start > max) {
        start = max - parseInt(max/100, 10);
      }

      this.location = (start + end) / 2;
      
      caption = this.chr + ': ' + start + '-' + end;
    } else {
      view = 'View';
      
      this.location = Math.floor(min + (this.coords.y - this.areaCoords.t) * scale);
      
      start = Math.floor(this.location - (Ensembl.location.length / 2));
      end   = Math.floor(this.location + (Ensembl.location.length / 2));
      
      if (start < 1) {
        start = 1;
      }
      
      caption = this.chr + ': ' + this.location;
    }
    
    url = this.baseURL.replace(/.+\?/, '?').replace(/%s/, this.chr + ':' + start + '-' + end);
    menu = [
      '<a href="/' + this.species.replace(/-/g, '/') + '/Location/' + view + url + '">Jump to location ' + view + '</a>',
      '<a href="/' + this.species.replace(/-/g, '/') + '/Location/Chromosome' + url + '">Chromosome summary</a>'
    ];
    
    this.buildMenu(menu, caption);
  },

  populateRegion: function () {
    var myself = this;
    
    var menu, caption, start, end, tmp, razl1, razl2, href;
    var min = this.start;
    var max = this.end;
        
    var locationView = !!window.location.pathname.match(/\/Location\//);
    var variationGene = !!window.location.pathname.match(/\/Variation_Gene\/Image/);
    var scale = this.midpointImg && this.midpointChr ? (this.midpointChr - min + 1 + max) / (this.areaCoords.r - this.areaCoords.l) : (max - min + 1) / (this.areaCoords.r - this.areaCoords.l);
    
    var url = this.baseURL;
    
    // Gene, transcript views
    function notLocation() {
      url = url.replace(/.+\?/, '?');
      
      menu = [
        '<a href="' + myself.speciesPath + '/Location/View' + url + '">Jump to location View</a>',
        '<a href="' + myself.speciesPath + '/Location/Chromosome' + url + '">Chromosome summary</a>'
      ];
    }
    
    // Multi species view
    function multi() {
      var label = start ? 'region' : 'location';
      
      menu = [ '<a href="' + url.replace(/;action=primary;id=\d+/, '') + '">Realign using this ' + label + '</a>' ];
        
      if (myself.multi) {
        menu.push('<a href="' + url + '">Use ' + label + ' as primary</a>');
      } else {
        menu.push('<a href="' + url.replace(/[rg]\d+=[^;]+;?/g, '') + '">Jump to ' + label + '</a>');
      }
    
      caption = myself.species.replace(/_/g, ' ') + ' ' + myself.chr + ':' + (start ? start + '-' + end : myself.location);
    }
    
    // AlignSlice view
    function align() {
      var label = start ? 'region' : 'location';
      label += myself.species == Ensembl.species ? '' : ' on ' + Ensembl.species.replace(/_/g, ' ');

      if((myself.splitFlag > 0) && myself.midpointChr) {
         var regexp1 = new RegExp( '^([^:]+:)(\\d+)-(\\d+)$');
         var myr = Ensembl.coreParams.r.match(regexp1);
         var core_params = myself.splitFlag == 1 ? (myr[1] + myr[2] + '-' + myself.midpointChr) : (myr[1] + '1-' + myr[3]);
         menu = [ '<a href="' + url.replace(/%s/, core_params + ';align_start=' + start + ';align_end=' + end) + '">Jump to best aligned ' + label + '</a>' ];
      } else {      
         menu = [ '<a href="' + url.replace(/%s/, Ensembl.coreParams.r + ';align_start=' + start + ';align_end=' + end) + '">Jump to best aligned ' + label + '</a>' ];
      }

      caption = 'Alignment: ' + (start ? start + '-' + end : myself.location);
    }
    
    // Region select
    if (this.coords.r) {
      start = Math.floor(min + (this.coords.s - this.areaCoords.l) * scale);
      end   = Math.floor(min + (this.coords.s + this.coords.r - this.areaCoords.l) * scale);

      if (this.midpointImg && this.midpointChr) {
        if (start > this.midpointChr) { // recalculate start
          start = Math.floor(1 + (this.coords.s - this.areaCoords.l - this.midpointImg) * scale);
        }

        if (end > this.midpointChr) { // recalculate end
          end = Math.floor(1 + (this.coords.s + this.coords.r - this.areaCoords.l - this.midpointImg) * scale);
        }

        if (end < min && end > max)  {
          razl1 = min - end;
          razl2 = end - max;

          if (razl1 < razl2)  {
            end = min;
          } else {
            end = max;
          }
        }

        if ((start > min && end >= min && start > end) || (start <= max && end < max && start > end) || (start < max && end >= min)) {
          tmp   = start;
          start = end;
          end   = tmp;
        }

        if (start > max && start < min)  {
          start = min;
        }

        if (this.strand == 1) {
          if (start < end) {
            this.location = (start + end) / 2;
          } else {
            this.location =  start + (this.midpointChr - start + end) / 2;
            
            if (this.location > this.midpointChr) {
              this.location = this.location - this.midpointChr;
            }
          }
        } else {
          this.location = (2 * this.start + 2 * this.end - start - end) / 2;
          
          tmp   = start;
          start = this.end + this.start - end;
          end   = this.end + this.start - tmp;
        }
      } else {
        if (start > end) {
          tmp   = start;
          start = end;
          end   = tmp;
        }

        if (start < min) {
          start = min;
        }

        if (end > max) {
          end = max;
        }

        if (this.strand == 1) {
          this.location = (start + end) / 2;
        } else {
          this.location = (2 * this.start + 2 * this.end - start - end) / 2;
          
          tmp   = start;
          start = this.end + this.start - end;
          end   = this.end + this.start - tmp;
        }
      }

      if (this.align === true) {
        align();
      } else {
        url = url.replace(/%s/, this.chr + ':' + start + '-' + end);
        caption = 'Region: ' + this.chr + ':' + start + '-' + end;
        
        if (!locationView && !variationGene) {
          notLocation();
        } else if (this.multi !== false) {
          multi();
        } else {
            var param_min	= 0;
       	    var param_max	= 0;

       	    if (variationGene) {
       	      param_min   = min;
       	      param_max   = max;
            }

            if ( (end < start) && this.midpointChr && this.midpointImg ) {
              menu = [
                '<a href="' + url + '">Jump to region (' + (this.midpointChr - start + end) + ' bp)</a>',
                '<a href="' + this.zoomURL(1, param_min, param_max) + '">Centre here</a>'
              ];
            } else {
              menu = [
                '<a href="' + url + '">Jump to region (' + (end - start) + ' bp)</a>',
                '<a href="' + this.zoomURL(1, param_min, param_max) + '">Centre here</a>'
              ];
            }
          

        }
      }
    } else { // Point select
      this.location = Math.floor(min + (this.coords.x - this.areaCoords.l) * scale);

      if ((this.location > this.midpointChr) && this.midpointChr && this.midpointImg )  { // recalculate this.location
        this.location = Math.floor(1 + (this.coords.x - this.areaCoords.l - this.midpointImg) * scale);
      }
      
      if (this.align === true) {
        url = this.zoomURL(1/10);
        align();
      } else {
        url = this.zoomURL(1);
        caption = 'Location: ' + this.chr + ':' + this.location;
        
        if (!locationView) {
          notLocation();
        } else if (this.multi !== false) {
          multi();
        } else {
          menu = [
            '<a href="' + this.zoomURL(10) + '">Zoom out x10</a>',
            '<a href="' + this.zoomURL(5)  + '">Zoom out x5</a>',
            '<a href="' + this.zoomURL(2)  + '">Zoom out x2</a>',
            '<a href="' + url  + '">Centre here</a>'
          ];
          
          // Only add zoom in links if there is space to zoom in to.
          $.each([2, 5, 10], function () {
            href = myself.zoomURL(1 / this);
            
            if (href !== '') {
              menu.push('<a href="' + href + '">Zoom in x' + this + '</a>');
            }
          });
        }
      }
    }
    
    this.buildMenu(menu, caption);
  },
   
  zoomURL: function (scale, min, max) {

    if ((this.start > this.end) && this.midpointChr && this.midpointImg) { //recalculate w
      var w = (this.midpointChr - this.start + 1 + this.end) * scale;
      
      if (w < 1) {
       return '';
      }
      
      // recalculate start, end
      var start = Math.round(this.location - (w - 1) / 2);
      var end   = Math.round(this.location + (w - 1) / 2); // No constraints on end - can't know how long the chromosome is, and perl will deal with overflow
      
      if (start < 1) {
        start = this.midpointChr + start;
      }
      
      if (end > this.midpointChr) {
        end = end - this.midpointChr;
      }

      if(min > 0 && max > 0) {
        if (end < min && end > max)  {
          var razl1 = min - end;
          var razl2 = end - max;

          if (razl1 < razl2)  {
            end = min;
          } else {
            end = max;
          }
        }
        if (start > max && start < min)  {
          start = min;
        }
      }
      
      if (this.align === true) {
        return this.baseURL.replace(/%s/, Ensembl.coreParams.r + ';align_start=' + start + ';align_end=' + end); 
      } else {
        return this.baseURL.replace(/%s/, this.chr + ':' + start + '-' + end);
      }
    } else if((this.splitFlag > 0) && this.midpointChr) {

      var regexp1 = new RegExp( '^([^:]+:)(\\d+)-(\\d+)$');
      var myr = Ensembl.coreParams.r.match(regexp1);
      var core_params = this.splitFlag == 1 ? (myr[1] + myr[2] + '-' + this.midpointChr) : (myr[1] + '1-' + myr[3]);

      var width = this.splitFlag == 1 ? this.midpointChr - parseInt(myr[2], 10) + 1 : parseInt(myr[3], 10);    

      var w = width * scale;
      if (w < 1) {
        return '';
      }

      var start = Math.round(this.location - (w - 1) / 2);
      var end   = Math.round(this.location + (w - 1) / 2); // No constraints on end - can't know how long the chromosome is, and perl will deal with overflow
      if (start < 1) {
        start = this.start;
      }

      //the following should be added to the base version of the func:
      if(end > this.end) {
        end = this.end;
      }

      if (this.align === true) {
        return this.baseURL.replace(/%s/, core_params + ';align_start=' + start + ';align_end=' + end);        
      } else {
        return this.baseURL.replace(/%s/, this.chr + ':' + start + '-' + end);
      }
     
    } else {
      return this.base(scale, min, max);
    }
  }
}, { template: Ensembl.Panel.ZMenu.template });
