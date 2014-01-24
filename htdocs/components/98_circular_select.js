Raphael.fn.karyoFeatures = function (o, margin, size) {
    // init
    var paper = this;
    var rad = Math.PI / 180;
    var radius = 2 + size / 2;
    var centre = margin + size / 2;
    var colour1 = 'red';
    var colour2 = '#9B0000';
    var blankSectorAngle = 60; // non-circular regions have a blank sector at the top        
    var angleRange = o.isCircular ? 360 : (360 - blankSectorAngle);
    var angleOffset = o.isCircular ? 0 : (blankSectorAngle / 2);

    function angleMarker(myAngle, myCount, myLink) {

        // attach label
        var labelRadius = radius + 20;
        var labelOffsetRad = Math.atan(18 / labelRadius);

        var labelX = centre + (labelRadius * Math.sin((myAngle * rad) - labelOffsetRad));
        var labelY = centre - (labelRadius * Math.cos((myAngle * rad) - labelOffsetRad));
        var label = paper.text(labelX, labelY, myCount).attr({
            fill: colour2
        }).hide();

        // attach arrow
        var opacity = myCount / 5;
        var arrowDesc = ['M', centre, centre - radius, 'L', centre - 5, centre - radius - 10, 'L', centre + 5, centre - radius - 10, 'L', centre, centre - radius].join(' ');
        var arrow = paper.path(arrowDesc).attr({

            stroke: colour2,
            fill: colour1,
            rotation: myAngle + ' ' + centre + ' ' + centre,
            "fill-opacity": opacity

        }).mouseover(function () {

            if (!$.browser.msie && !$.browser.opera) {
                this.toFront();
            } // toFront() breaks ie and opera, info http://github.com/DmitryBaranovskiy/raphael/issues#issue/126
            this.animate({
                "fill-opacity": 0.5,
                scale: 2
            }, 200, '<', function () {
                label.show();
            });
            this.node.style.cursor = "pointer";

        }).mouseout(function () {

            label.hide();
            this.animate({
                "fill-opacity": opacity,
                scale: 1
            }, 500, '>');
            this.node.style.cursor = "null";

        });

        // add link
        if (myLink) { 
          arrow.click(function () {
            document.location.href = myLink;
          });
        } 

    }

    // work out unique marker positions
    var markers = [];
    var links = [];
    var angle;
    var i;

    for (i = 0; i < o.features.length; i++) {

        angle = parseInt(angleOffset + (angleRange * (o.features[i]) / o.regionLength), 10);
        if (angle === 360) {
            angle = 0;
        } // 360 and 0 overlap on chart and should be grouped
        // group with other markers if they are within 1 degree either way
        if (!markers[angle] && markers[angle - 1]) {
            angle -= 1;
        } else if (!markers[angle] && markers[angle + 1]) {
            angle += 1;
        }
        markers[angle] = markers[angle] ? markers[angle] + 1 : 1;
        // is there a link to use?
        if (typeof(o.featureLinks) === 'object') { links[angle] = o.featureLinks[i]; }
    }

    // draw the markers     
    for (angle in markers) {
        if (markers[angle]) {
            angleMarker(angle, markers[angle], links[angle]);
        }
    }

    if ($.browser.opera) {
        // load event won't fire if image has already loaded from cache so trigger it if needed
        // (opera only) see comments here http://api.jquery.com/load-event/
        $(this).each(function () {
            if (this.complete) {
                $(this).trigger("load");
            }
        });
    }

    return $(this);
};

Raphael.fn.pieChartCirc = function (cx, cy, r, stroke, target, bp, reg_type, cIndex, margin, resized) {
    var paper = this;
    var rad = Math.PI / 180;
    var chart = this.set();

    var current = null;
    var handle_1 = null;
    var handle_2 = null;

    var imgheight = r * 2;
    var imgwidth = r * 2;
    var angle_text = paper.text(cx, cy, '');
    var static_x;
    var static_y;
    var static_flag;

    var url_re;

    var paramObj = {
          ind    : 0,
          url_re : null,
          url    : ""
    };

    var url_part1;
    var url_part2;
    var start_reg;
    var end_reg;
    var start_point;
    var end_point;

    bp = parseInt(bp, 10);

    var patt1 = /\/(Genome)/i;
    var patt2 = /\/(Chromosome)/i;

    var mypg    = window.location.href.match(patt1);
    var mychrpg = window.location.href.match(patt2);

    var cind = cIndex;
    if (cind > 0) {
        cind--;
    }

    if ((cIndex) && (mypg === null)) { //Multi
        paramObj.ind = cind;
        if (cind > 0) {
            paramObj.url_re = new RegExp('^(.+)r' + cind + '=([\\w-]+)(:|%3A)(\\d+)-(\\d+)(:|%3A|;|$)(.*)$');
        } else {
            paramObj.url_re = new RegExp('^(.+)r=([\\w-]+)(:|%3A)(\\d+)-(\\d+)(:|%3A|;|$)(.*)$');
        }
        paramObj.url = window.location.href;
    }

    if ((cind > 0) && (mypg === null)) {
        url_re = new RegExp('^(.+)r' + cind + '=([\\w-]+)(?::|%3A)(\\d+)-(\\d+)(?::|%3A)(?:-?1);?(.*)$');
    } else {
        //^(.+) consumes as much of the pattern as possible before matching 'r='; this way that the last match is taken in consideration
        url_re = new RegExp('^(.+)r=([\\w-]+)(?::|%3A)(\\d+)-(\\d+);?(.*)$');
    }

    var myr = window.location.href.match(url_re);

    if (myr !== null) {

        url_part1 = myr[1];
        start_reg = parseInt(myr[3], 10);
        end_reg = parseInt(myr[4], 10);
        url_part2 = myr[5];

        //no start/end params in the url for any other chr apart from the one with region name = reg_type
        if ((mypg !== null) && (myr[2] !== reg_type)) {
            start_reg = parseInt(bp / 3, 10);
            end_reg = start_reg + parseInt(bp / 9, 10);
        }

    } else {
        var url_re2 = new RegExp('^(.+)(\/)(\\w+)(\\W(.*)|$)');
        myr = window.location.href.match(url_re2);
        url_part1 = myr[1] + myr[2] + myr[3] + '?';
        url_part2 = myr[5] !== null ? myr[5] : '';

        //no start/end params in the url
        start_reg = parseInt(bp / 3, 10);
        end_reg = start_reg + parseInt(bp / 9, 10);
    }

    if ((cIndex) && (mypg !== null)) { //Genome page
        url_part1 = url_part1.replace('Genome', 'View');
    }
    if (mychrpg !== null) {            //Chromosome page
        url_part1 = url_part1.replace('Chromosome', 'View');
    }


    if ((end_reg > start_reg) && (end_reg > bp)) {
        end_reg = bp;
    }
    if ((end_reg <= start_reg) && (start_reg > bp)) {
        start_reg = bp;
    }

    start_point = 90 - start_reg / (bp / 360);
    if (start_point < 0) {
        start_point = 360 + start_point;
    }

    end_point = 90 - end_reg / (bp / 360);
    if (end_point < 0) {
        end_point = 360 + end_point;
    }


    if (Math.abs(end_point - start_point) < 2) {
        if (start_point >= end_point) {
            start_point = start_point + 3 - Math.abs(end_point - start_point);
        } else {
            end_point = end_point + 3 - Math.abs(end_point - start_point);
        }
    }


    $(target).click(function (event) {

        if (resized) {
            return;
        }

        if (s1) {
            s1.remove();
            handle_1.remove();
            handle_2.remove();
            angle_text.remove();
        }
        if (current) {
            current.remove();
            handle_1.remove();
            handle_2.remove();
            angle_text.remove();
        }

        var offset = $(target).offset();
        var xclick = (event.pageX - offset.left - margin) - (imgwidth / 2); // 370 the css property of the div 11 is half the with of the image
        var yclick = ((event.pageY - offset.top - margin) - (imgheight / 2)) * -1;
        var theta = Math.atan(yclick / xclick) * 360 / 2 / Math.PI;

        if (xclick >= 0 && yclick >= 0) {
            theta = theta;
        } else if (xclick < 0 && yclick >= 0) {
            theta = 180 + theta;
        } else if (xclick < 0 && yclick < 0) {
            theta = 180 + theta;
        } else if (xclick > 0 && yclick < 0) {
            theta = 360 + theta;
        }

        var color = "hsb(" + 1 + ", 1, .5)";
        s = sector(cx, cy, r, theta - 10, theta + 10, {
            fill: color,
            stroke: stroke,
            "stroke-width": 0.5,
            "opacity": 0.6
        }, reg_type, 1); //1
        current = s;
    });


    function sector(cx, cy, r, startAngle, endAngle, params, reg_type, sectorclick) {

        var x1 = cx + r * Math.cos(-startAngle * rad),
            x2 = cx + r * Math.cos(-endAngle * rad),
            y1 = cy + r * Math.sin(-startAngle * rad),
            y2 = cy + r * Math.sin(-endAngle * rad);

        var large_arc = 0;
        var sweep_flg = 0;

        var start_reg = (90 - endAngle) * (bp / 360);
        if (start_reg < 0) {
            //console.log(' start_reg BEFORE: ' + parseInt(start_reg, 10) + ' angle: ' + endAngle);
            start_reg = parseInt(bp, 10) + parseInt(start_reg, 10);
        }
        //console.log(' start_reg : ' + parseInt(start_reg, 10));
        var end_reg = (90 - startAngle) * (bp / 360);
        if (end_reg < 0) {
            //console.log(' end_reg BEFORE: ' + parseInt(end_reg, 10) + ' angle: ' +  startAngle);
            end_reg = parseInt(bp, 10) + parseInt(end_reg, 10);
        }
        //console.log(' end_reg : ' + parseInt(end_reg, 10));
        var sub = parseInt(end_reg - start_reg, 10);
        var bp_h = parseInt(bp / 2, 10);
        //console.log('sub: '+ sub + ' bp_half:  ' + bp_h);
        if (((sub > 0) && (sub > bp_h)) || ((sub < 0) && (Math.abs(sub) < bp_h))) {
            large_arc = 1;
        }

        var sector_path = ["M", cx, cy, "L", x1, y1, "A", r, r, 0, large_arc, sweep_flg, x2, y2, "z"];

        if (angle_text) {
            angle_text.remove();
        }
        if (sectorclick) {
            var txt_c = parseInt(start_reg, 10) + '-' + parseInt(end_reg, 10);
            angle_text = paper.text(cx, cy, txt_c);
        }

        var s = paper.path(sector_path).attr(params);
        //current = s;
        s.click(function (event) {

            if (event.stopPropagation) {
                // this code is for Mozilla and Opera
                event.stopPropagation();
            } else if (window.event) {
                // this code is for IE
                window.event.cancelBubble = true;
            }

            var elem = $(event.target);
            //console.log('sector click');
            if (sectorclick) {
                if ((cIndex > 0) && (mypg === null)) { //Multi
                    var start_param = parseInt(start_reg, 10);
                    var end_param = parseInt(end_reg, 10);
                    if (paramObj.ind > 0) {
                        paramObj.url = paramObj.url.replace(paramObj.url_re, "$1r" + paramObj.ind + "=$2$3" + start_param + "-" + end_param + "$6$7");
                    } else {
                        paramObj.url = paramObj.url.replace(paramObj.url_re, "$1r=$2$3" + start_param + "-" + end_param + "$6$7");
                    }
                } else {
                    if (url_part2) {
                        paramObj.url = url_part1 + 'r=' + reg_type + ':' + parseInt(start_reg, 10) + '-' + parseInt(end_reg, 10) + ';' + url_part2;
                    } else {
                        paramObj.url = url_part1 + 'r=' + reg_type + ':' + parseInt(start_reg, 10) + '-' + parseInt(end_reg, 10) + ';';
                    }
                }
                document.location.href = paramObj.url;
            }
        }).mouseover(function () {
            s.animate({
                fill: "#900",
                opacity: 1
            }, 200);
        }).mouseout(function () {
            s.animate({
                opacity: 0.4
            }, 200);
            //  txt.animate({opacity: .3}, ms);
        });

        $(target).data('sector', s);

        if (resized) {
            return s;
        }

        handle_1 = paper.circle(x1, y1, 3).attr({
            fill: 'yellow'
        });
        handle_2 = paper.circle(x2, y2, 3).attr({
            fill: 'blue'
        });

        var drag_handle_1 = function (event) {
            static_x = handle_2.attrs.cx;
            static_y = handle_2.attrs.cy;
            static_flag = 2;
            if (s1) {
                s1.remove();
                handle_1.remove();
                handle_2.remove();
                angle_text.remove();
            }
        };


        var dragend_handle_1 = function (event) {
            $(this).attr("fill", 'green');
        };

        var drag_handle_2 = function (event) {
            static_x = handle_1.attrs.cx;
            static_y = handle_1.attrs.cy;
            static_flag = 1;
            if (s1) {
                s1.remove();
                handle_1.remove();
                handle_2.remove();
                angle_text.remove();
            }
        };

        var dragend_handle_2 = function (event) {
            $(this).attr("fill", 'purple');
        };

        $(handle_1.node).bind('dragstart', drag_handle_1);
        $(handle_1.node).bind('drag', updateSector);
        $(handle_1.node).bind('drag', dragend_handle_1);
        $(handle_2.node).bind('dragstart', drag_handle_2);
        $(handle_2.node).bind('drag', updateSector);
        $(handle_2.node).bind('drag', dragend_handle_2);

        return s;

    } //function sector

    function get_angle(static_y_, cy_, sx_, sy_) {

        var alfa = Math.asin((static_y - cy) / r) / rad * (-1);

        if ((sx_ > 0) && (sy_ < 0)) { //4
            alfa = alfa;
        }
        if ((sx_ > 0) && (sy_ > 0)) { //3
            alfa = 360 + alfa;
        }
        if ((sx_ < 0) && (sy_ > 0)) { //2
            alfa = 180 - alfa;
        }
        if ((sx_ < 0) && (sy_ < 0)) { //1
            alfa = 180 - alfa;
        }

        return ({
            angle: alfa
        });

    }

    function updateSector(event) {
        var offset = $(target).offset();
        var xclick_ = (event.pageX - offset.left - margin) - (imgwidth / 2); // 370 the css property of the div 11 is half the with of the image
        var yclick_ = ((event.pageY - offset.top - margin) - (imgheight / 2)) * -1;
        //console.log('margin is: ' + margin);
        var theta_ = Math.atan(yclick_ / xclick_) * 360 / 2 / Math.PI;

        if (xclick_ >= 0 && yclick_ >= 0) {
            theta_ = theta_;
        } else if (xclick_ < 0 && yclick_ >= 0) {
            theta_ = 180 + theta_;
        } else if (xclick_ < 0 && yclick_ < 0) {
            theta_ = 180 + theta_;
        } else if (xclick_ > 0 && yclick_ < 0) {
            theta_ = 360 + theta_;
        }

        //console.log('dynamic_angle:  ' + theta_);
        if (current) {
            current.remove();
            handle_1.remove();
            handle_2.remove();
            angle_text.remove();
        }

        // coordinates determining the quad for the static handle
        var sx = static_x - r - margin;
        var sy = static_y - r - margin;

        //get the angle for the static handle
        var stat_angle = get_angle(static_y, cy, sx, sy, r);
        //console.log('static_angle : ' + stat_angle.angle);
        color = "hsb(" + 1 + ", 1, .5)";
        if (static_flag === 2) {
            s = sector(cx, cy, r, theta_, stat_angle.angle, {
                fill: color,
                stroke: stroke,
                "stroke-width": 0.5,
                "opacity": 0.6
            }, reg_type, 1);
        } else {
            s = sector(cx, cy, r, stat_angle.angle, theta_, {
                fill: color,
                stroke: stroke,
                "stroke-width": 0.5,
                "opacity": 0.6
            }, reg_type, 1);
        }

        current = s;
        //console.log('xclick:', xclick_ + ' yclick: ', yclick_);
    }


    var color = "hsb(" + 1 + ", 1, .5)";
    var s1 = sector(cx, cy, r, end_point, start_point, {
        fill: color,
        stroke: stroke,
        "stroke-width": 0.5,
        "opacity": 0.6
    }, reg_type, 0);
    current = s1;
    //setting the text outside the function because the end_point - start_point coordinates might have been manipulated (if Math.abs(end_point-start_point) < 1 )
    //and in this case they wouldn't reflect the authentic start_reg and end_reg
    var txt_c1 = parseInt(start_reg, 10) + '-' + parseInt(end_reg, 10);
    angle_text = paper.text(cx, cy, txt_c1);


    return chart;

}; //pieChartCirc

Raphael.fn.pieChart = function (cx, cy, r, stroke, target, bp, reg_type, cIndex, margin, resized) {
    var paper = this;
    var rad = Math.PI / 180;
    var chart = this.set();

    var current = null;
    var handle_1 = null;
    var handle_2 = null;
  
    var trackObj = {
         prev1 : 0,
         prev2 : 0
    };
    var paramObj = {
          ind    : 0,
          url_re : null,
          url    : ""
    };

    var imgheight = r * 2;
    var imgwidth = r * 2;
    var angle_text = paper.text(cx, cy, '');
    var static_x;
    var static_y;
    var static_flag;
    var url_re;
    var url_part1;
    var url_part2;
    var start_reg;
    var end_reg;
    var start_point;
    var end_point;

    bp = parseInt(bp, 10);


    var patt1 = /\/(Genome)/i;
    var patt2 = /\/(Chromosome)/i;

    var mypg = window.location.href.match(patt1);
    var mychrpg = window.location.href.match(patt2);

    var cind = cIndex;
    if (cind > 0) {
        cind--;
    }

    if ((cIndex) && (mypg === null)) { //Multi
        paramObj.ind = cind;
        if (cind > 0) {
            paramObj.url_re = new RegExp('^(.+)r' + cind + '=([\\w-]+)(:|%3A)(\\d+)-(\\d+)(:|%3A|;|$)(.*)$');
        } else {
            paramObj.url_re = new RegExp('^(.+)r=([\\w-]+)(:|%3A)(\\d+)-(\\d+)(:|%3A|;|$)(.*)$');
        }
        paramObj.url = window.location.href;
    }

    if ((cind > 0) && (mypg === null)) {
        url_re = new RegExp('^(.+)r' + cind + '=([\\w-]+)(?::|%3A)(\\d+)-(\\d+)(?::|%3A)(?:-?1);?(.*)$');
    } else {
        //^(.+) consumes as much of the pattern as possible before matching 'r='; this way that the last match is taken in consideration
        url_re = new RegExp('^(.+)r=([\\w-]+)(?::|%3A)(\\d+)-(\\d+);?(.*)$');
    }

    var myr = window.location.href.match(url_re);

    if (myr !== null) {
        url_part1 = myr[1];
        start_reg = parseInt(myr[3], 10);
        end_reg = parseInt(myr[4], 10);
        url_part2 = myr[5];

        //no start/end params in the url for any other chr apart from the one with region name = reg_type
        if ((mypg !== null) && (myr[2] !== reg_type)) {
            start_reg = parseInt(bp / 3, 10);
            end_reg = start_reg + parseInt(bp / 9, 10);
        }

    } else {
        var url_re2 = new RegExp('^(.+)(\/)(\\w+)(\\W(.*)|$)');
        myr = window.location.href.match(url_re2);
        url_part1 = myr[1] + myr[2] + myr[3] + '?';
        url_part2 = myr[5] !== null ? myr[5] : '';

        //no start/end params in the url
        start_reg = parseInt(bp / 3, 10);
        end_reg = start_reg + parseInt(bp / 9, 10);
    }

    if ((cIndex) && (mypg !== null)) { //Genome page 
        url_part1 = url_part1.replace('Genome', 'View');
    }
    if (mychrpg !== null) {            //Chromosome page
	url_part1 = url_part1.replace('Chromosome', 'View');
    }

    if ((end_reg > start_reg) && (end_reg > bp)) {
        end_reg = bp;
    }
    if ((end_reg <= start_reg) && (start_reg > bp)) {
        start_reg = bp;
    }

    //var start_point = 90 - start_reg / (bp/360);
    start_point = 60 - start_reg / (bp / 300);
    if (start_point < 0) {
        start_point = 360 + start_point;
    }

    //var end_point =  90 - end_reg / (bp/360);
    end_point = 60 - end_reg / (bp / 300);
    if (end_point < 0) {
        end_point = 360 + end_point;
    }

    if ((start_point === 60) || (start_point === 120)) {
        start_point = start_point - 0.000000001;
    }

    if ((end_point === 60) || (end_point === 120)) {
        end_point = end_point - 0.000000001;
    }


    if (Math.abs(end_point - start_point) < 2) {
        if (start_point >= end_point) {
            start_point = start_point + 3 - Math.abs(end_point - start_point);
        } else {
            end_point = end_point + 3 - Math.abs(end_point - start_point);
        }
    }

    $(target).click(function (event) {
        //console.log('click!!!');
        if (resized) {
            return;
        }
        var offset = $(target).offset();
        var xclick = (event.pageX - offset.left - margin) - (imgwidth / 2); // 370 the css property of the div 11 is half the with of the image
        var yclick = ((event.pageY - offset.top - margin) - (imgheight / 2)) * -1;

        var theta = Math.atan(yclick / xclick) * 360 / 2 / Math.PI;

        if (xclick >= 0 && yclick >= 0) {
            theta = theta;
        } else if (xclick < 0 && yclick >= 0) {
            theta = 180 + theta;
        } else if (xclick < 0 && yclick < 0) {
            theta = 180 + theta;
        } else if (xclick > 0 && yclick < 0) {
            theta = 360 + theta;
        }

        //console.log('THETA: ' + theta); 
        if ((theta < 120) && (theta > 60)) {
            return;
        }

        if (s1) {
            s1.remove();
            handle_1.remove();
            handle_2.remove();
            angle_text.remove();
        }
        if (current) {
            current.remove();
            handle_1.remove();
            handle_2.remove();
            angle_text.remove();
        }
        trackObj.prev1 = 0;
        trackObj.prev2 = 0;

        if ((theta >= 50) && (theta <= 60)) {
            theta = 49.999999999;
        }
        if ((theta <= 130) && (theta >= 120)) {
            theta = 130.000000001;
        }

        var theta_1 = theta + 10;
        var theta_2 = theta - 10;

        var color = "hsb(" + 1 + ", 1, .5)";
        s = sector(cx, cy, r, theta_2, theta_1, {
            fill: color,
            stroke: stroke,
            "stroke-width": 0.5,
            "opacity": 0.6
        }, reg_type, 1); //1
        current = s;

    });


    function sector(cx, cy, r, startAngle, endAngle, params, reg_type, sectorclick) {
        var x1 = cx + r * Math.cos(-startAngle * rad),
            x2 = cx + r * Math.cos(-endAngle * rad),
            y1 = cy + r * Math.sin(-startAngle * rad),
            y2 = cy + r * Math.sin(-endAngle * rad);

        var large_arc = 0;
        var sweep_flg = 0;

        //used for calculation of large_arc and sweep_flg
        var start_reg = (90 - endAngle) * (bp / 360);
        if (start_reg < 0) {
            start_reg = parseInt(bp, 10) + parseInt(start_reg, 10);
        }

        var end_reg = (90 - startAngle) * (bp / 360); //360
        if (end_reg < 0) {
            end_reg = parseInt(bp, 10) + parseInt(end_reg, 10);
        }

        //used for actual start reg and end reg parameter
        var start_reg_2 = (60 - endAngle) * (bp / 300);
        if (start_reg_2 < 0) {
            start_reg_2 = parseInt(bp, 10) + 60 * (bp / 300) + parseInt(start_reg_2, 10);
        }
        if (start_reg_2 > bp) {
            start_reg_2 = bp;
        }
        if (start_reg_2 <= 0) {
            start_reg_2 = 1;
        }

        var end_reg_2 = (60 - startAngle) * (bp / 300);
        if (end_reg_2 < 0) {
            end_reg_2 = parseInt(bp, 10) + 60 * (bp / 300) + parseInt(end_reg_2, 10);
        }
        if (end_reg_2 > bp) {
            end_reg_2 = bp;
        }
        if (end_reg_2 <= 0) {
            end_reg_2 = 1;
        }


        if (end_reg_2 < start_reg_2) {
            var tmp_reg = start_reg_2;
            start_reg_2 = end_reg_2;
            end_reg_2 = tmp_reg;
        }

        //console.log('start_reg_2 : ' + parseInt(start_reg, 10));
        //console.log('end_reg_2 :   ' + parseInt(end_reg, 10));
        var sub = parseInt(end_reg - start_reg, 10);
        var bp_h = parseInt(bp / 2, 10);

        if (((sub > 0) && (sub > bp_h))) {
            large_arc = 1;
        }

        if (((sub < 0) && (Math.abs(sub) < bp_h))) {
            sweep_flg = 1;
            //console.log('sub:  ' + sub + ' Math.abs(sub): ' + Math.abs(sub) + ' bp_h:  ' + bp_h);
        } else if (sub < 0) {
            large_arc = 1;
            sweep_flg = 1;
            //console.log('sub:  ' + sub + ' Math.abs(sub): ' + Math.abs(sub) + ' bp_h:  ' + bp_h);
        }
        //console.log('large_arc: ' + large_arc + ' sweep_flg: ' + sweep_flg);
        var sector_path = ["M", cx, cy, "L", x1, y1, "A", r, r, 0, large_arc, sweep_flg, x2, y2, "z"];

        if (angle_text) {
            angle_text.remove();
        }
        if (sectorclick) {
            if (parseInt(start_reg_2, 10) === 0) {
                start_reg_2 = 1;
            }
            if (parseInt(end_reg_2, 10) === 0) {
                end_reg_2 = 1;
            }
            var txt_c = parseInt(start_reg_2, 10) + '-' + parseInt(end_reg_2, 10);
            angle_text = paper.text(cx, cy, txt_c);
        }

        var s = paper.path(sector_path).attr(params);
        //current = s;
        s.click(function (event) {

            if (event.stopPropagation) {
                // this code is for Mozilla and Opera
                event.stopPropagation();
            } else if (window.event) {
                // this code is for IE
                window.event.cancelBubble = true;
            }

            var elem = $(event.target);
            //console.log('sectorclick='+sectorclick);
            
            if (sectorclick) {
                if ((cIndex > 0) && (mypg === null)) { //Multi
                    var start_param = parseInt(start_reg_2, 10);
                    var end_param = parseInt(end_reg_2, 10);
                    if (paramObj.ind > 0) {
                        paramObj.url = paramObj.url.replace(paramObj.url_re, "$1r" + paramObj.ind + "=$2$3" + start_param + "-" + end_param + "$6$7");
                    } else {
                        paramObj.url = paramObj.url.replace(paramObj.url_re, "$1r=$2$3" + start_param + "-" + end_param + "$6$7");
                    }
                } else {
                    //console.log('sc1.2');
                    if (url_part2) {
                        paramObj.url = url_part1 + 'r=' + reg_type + ':' + parseInt(start_reg_2, 10) + '-' + parseInt(end_reg_2, 10) + ';' + url_part2;
                    } else {
                        paramObj.url = url_part1 + 'r=' + reg_type + ':' + parseInt(start_reg_2, 10) + '-' + parseInt(end_reg_2, 10) + ';';
                    }
                }
                document.location.href = paramObj.url;
            }
        }).mouseover(function () {
            s.animate({
                fill: "#900",
                opacity: 1
            }, 200);
        }).mouseout(function () {
            s.animate({
                opacity: 0.4
            }, 200);
            //  txt.animate({opacity: .3}, ms); 
        });

        $(target).data('sector', s);

        if (resized) {
            return s;
        }
        handle_1 = paper.circle(x1, y1, 3).attr({
            fill: 'yellow'
        });
        handle_2 = paper.circle(x2, y2, 3).attr({
            fill: 'blue'
        });

        var drag_handle_1 = function (event) {
            static_x = handle_2.attrs.cx;
            static_y = handle_2.attrs.cy;
            static_flag = 2;
            if (s1) {
                s1.remove();
                handle_1.remove();
                handle_2.remove();
                angle_text.remove();
            }
        };


        var dragend_handle_1 = function (event) {
            $(this).attr("fill", 'green');
        };

        var drag_handle_2 = function (event) {
            static_x = handle_1.attrs.cx;
            static_y = handle_1.attrs.cy;
            static_flag = 1;
            if (s1) {
                s1.remove();
                handle_1.remove();
                handle_2.remove();
                angle_text.remove();
            }
        };

        var dragend_handle_2 = function (event) {
            $(this).attr("fill", 'purple');
        };


        if ((startAngle !== 60) && (startAngle !== 120) && (!trackObj.prev1)) {
            $(handle_1.node).bind('dragstart', drag_handle_1);
            $(handle_1.node).bind('drag', updateSector);
            $(handle_1.node).bind('drag', dragend_handle_1);

        } else if (!trackObj.prev1) {

            trackObj.prev1 = startAngle;
        }

        if ((endAngle !== 60) && (endAngle !== 120) && (!trackObj.prev2)) {
            $(handle_2.node).bind('dragstart', drag_handle_2);
            $(handle_2.node).bind('drag', updateSector);
            $(handle_2.node).bind('drag', dragend_handle_2);

        } else if (!trackObj.prev2) {
            trackObj.prev2 = endAngle;
        }



        return s;
    } //function sector

    function get_angle(static_y_, cy_, sx_, sy_) {

        var alfa = Math.asin((static_y_ - cy_) / r) / rad * (-1);

        if ((sx_ > 0) && (sy_ < 0)) { //4
            alfa = alfa;
        }
        if ((sx_ > 0) && (sy_ > 0)) { //3
            alfa = 360 + alfa;
        }
        if ((sx_ < 0) && (sy_ > 0)) { //2
            alfa = 180 - alfa;
        }
        if ((sx_ < 0) && (sy_ < 0)) { //1
            alfa = 180 - alfa;
        }

        return ({
            angle: alfa
        });

    }


    var color = "hsb(" + 1 + ", 1, .5)";
    var s1 = sector(cx, cy, r, end_point, start_point, {
        fill: color,
        stroke: stroke,
        "stroke-width": 0.5,
        "opacity": 0.6
    }, reg_type, 0);
    current = s1;
    //setting the text outside the function because the end_point - start_point coordinates might have been manipulated (if Math.abs(end_point-start_point) < 1 )
    //and in this case they wouldn't reflect the authentic start_reg and end_reg
    var txt_c1 = parseInt(start_reg, 10) + '-' + parseInt(end_reg, 10);
    angle_text = paper.text(cx, cy, txt_c1);

    document.onmouseup = function () {

     if((handle_1 !== null)  && (handle_2 !== null))  {
        st_x_1 = handle_1.attrs.cx;
        st_y_1 = handle_1.attrs.cy;
        st_x_2 = handle_2.attrs.cx;
        st_y_2 = handle_2.attrs.cy;

        // get the angles
        var sx1 = st_x_1 - r;
        var sy1 = st_y_1 - r;
        var angle1 = get_angle(st_y_1, cy, sx1, sy1, r);

        var sx2 = st_x_2 - r;
        var sy2 = st_y_2 - r;
        var angle2 = get_angle(st_y_2, cy, sx2, sy2, r);

        var ang1 = angle1.angle;
        var ang2 = angle2.angle;

        //console.log('BEFORE: Angle 1: ' + ang1  + ' Angle 2: ' + ang2);
        if ((trackObj.prev1 === 60) || (trackObj.prev1 === 120)) {
            ang1 = parseInt(trackObj.prev1, 10) - 0.000000001;
            trackObj.prev1 = 0;
        }


        if ((trackObj.prev2 === 60) || (trackObj.prev2 === 120)) {
            ang2 = parseInt(trackObj.prev2, 10) - 0.000000001;
            trackObj.prev2 = 0;
        }

        if ((ang1 !== angle1.angle) || (ang2 !== angle2.angle)) {
            //console.log('Angle 1: ' + ang1  + ' Angle 2: ' + ang2);
            if (current) {
                current.remove();
                handle_1.remove();
                handle_2.remove();
                angle_text.remove();
            }
            s = sector(cx, cy, r, ang1, ang2, {
                fill: color,
                stroke: stroke,
                "stroke-width": 0.5,
                "opacity": 0.6
            }, reg_type, 1);
            current = s;
        }

     } 
     return;

    };

    function updateSector(event) {
        var offset = $(target).offset();
        var xclick_ = (event.pageX - offset.left - margin) - (imgwidth / 2); // 370 the css property of the div 11 is half the with of the image
        var yclick_ = ((event.pageY - offset.top - margin) - (imgheight / 2)) * -1;

        var theta_ = Math.atan(yclick_ / xclick_) * 360 / 2 / Math.PI;

        if (xclick_ >= 0 && yclick_ >= 0) {
            theta_ = theta_;
        } else if (xclick_ < 0 && yclick_ >= 0) {
            theta_ = 180 + theta_;
        } else if (xclick_ < 0 && yclick_ < 0) {
            theta_ = 180 + theta_;
        } else if (xclick_ > 0 && yclick_ < 0) {
            theta_ = 360 + theta_;
        }


        if (static_flag === 2) {

            if (trackObj.prev1 === 60) {
                if (theta_ > 60) {
                    theta_ = trackObj.prev1;
                } else {
                    trackObj.prev1 = 0;
                }
            }

            if (trackObj.prev1 === 120) {
                if (theta_ < 120) {
                    theta_ = trackObj.prev1;
                } else {
                    trackObj.prev1 = 0;
                }
            }

        } else {

            if (trackObj.prev2 === 60) {
                if (theta_ > 60) {
                    theta_ = trackObj.prev2;
                } else {
                    trackObj.prev2 = 0;
                }
            }

            if (trackObj.prev2 === 120) {
                if (theta_ < 120) {
                    theta_ = trackObj.prev2;
                } else {
                    trackObj.prev2 = 0;
                }
            }
        }

        //console.log('NEW theta_ : ' + theta_ +  ' trackObj.prev1:  ' + trackObj.prev1); 
        if ((theta_ < 120) && (theta_ > 60)) {
            var raz1 = Math.abs(theta_ - 120);
            var raz2 = Math.abs(theta_ - 60);
            if (raz1 < raz2) {
                theta_ = 120;
            } else {
                theta_ = 60;
            }
        }

        //console.log('dynamic_angle:  ' + theta_);
        if (current) {
            current.remove();
            handle_1.remove();
            handle_2.remove();
            angle_text.remove();
        }

        // get the angle static handle
        var sx = static_x - r - margin;
        var sy = static_y - r - margin;

        var stat_angle = get_angle(static_y, cy, sx, sy, r);
        //console.log('static_angle : ' + stat_angle.angle);	
        color = "hsb(" + 1 + ", 1, .5)";
        if (static_flag === 2) {
            s = sector(cx, cy, r, theta_, stat_angle.angle, {
                fill: color,
                stroke: stroke,
                "stroke-width": 0.5,
                "opacity": 0.6
            }, reg_type, 1);
        } else {

            s = sector(cx, cy, r, stat_angle.angle, theta_, {
                fill: color,
                stroke: stroke,
                "stroke-width": 0.5,
                "opacity": 0.6
            }, reg_type, 1);
        }

        current = s;
        //console.log('xclick :', xclick_ + ' yclick: ', yclick_);
    }

    return chart;
};


Ensembl.Panel.IdeogramPanel = Ensembl.Panel.extend({

    init: function () {
      this.base();
      this.raphael = Raphael.ninja();

      Ensembl.EventManager.register('hashChange', this, this.hashChange);
      Ensembl.EventManager.register('CircImage', this, this.CircImage);

      this.CircImage();

    },  

    hashChange: function (r) {
      this.params.updateURL = Ensembl.urlFromHash(this.params.updateURL);
      Ensembl.EventManager.trigger('CircImage');
    },

    CircImage: function () {


	var resized = 0;
        var raphael = this.raphael;
        if ($('img.circularImage', this.el).length) {

            var o = { 
              regionLength : 0,
              features     : [],
              featureLinks : [],
              isCircular   : 0
            };

            var lnsum = $(document).width() - 350;

            $('img.circularImage', this.el).each(function () {
                var multiCnt = $(this).prop('id').match(/^([\w\-]+)~(\d+)~(\d+)~(\d+)~~(\d+)$/);
                if (multiCnt !== null) {
                    if (parseInt(multiCnt[5], 10) > 1) {
                        var newsize = (lnsum / (parseInt(multiCnt[5], 10))) - 15;
                        var origsize = parseInt($(this).prop('width'), 10);
                        if (newsize < origsize) {
                            resized = 1;
			}
                    }
                }
            });

            $('img.circularImage', this.el).each(function (intIndex) {

              $(this).load(  function () {

                if ($.browser.webkit) { this.style.display = "none"; }

                var reg_type = $(this).prop('id').match(/^([\w\-]+)~/);
                var bp = $(this).prop('id').match(/^([\w\-]+)~(\d+)~/);
                var ifcirc = $(this).prop('id').match(/^([\w\-]+)~(\d+)~(\d+)~/);
		var cIndex = $(this).prop('id').match(/^([\w\-]+)~(\d+)~(\d+)~(\d+)/);
                multiCnt = $(this).prop('id').match(/^([\w\-]+)~(\d+)~(\d+)~(\d+)~~(\d+)$/);
                var kFeatures = $(this).prop('id').match(/^([\w\-]+)~(\d+)~(\d+)~(\d+)~(.+)~(.*)/);

                ifcirc = parseInt(ifcirc[3], 10);
                origsize = parseInt($(this).prop('width'), 10);

                if (multiCnt !== null) {
                    if (parseInt(multiCnt[5], 10) > 1) {
                        newsize = (lnsum / (parseInt(multiCnt[5], 10))) - 15;

			if (newsize >= origsize) {
                            newsize = origsize;
			} else {
                            newsize = parseInt(newsize, 10);

                            $(this).prop('width', newsize);
                            $(this).prop('height', newsize);

                            if ($('td.tdImg' + cIndex[4], this.el).length) {
                                $('td.tdImg' + cIndex[4], this.el).each(function () {
                                    var new_w = parseInt(newsize, 10) + 10;
                                    var new_h = parseInt(newsize, 10) + 10;
                                    $('td.tdImg' + cIndex[4], this.el).prop('width', new_w);
                                    $('td.tdImg' + cIndex[4], this.el).prop('height', new_h);
                                });
                            }
                        } //else
                    }
                }

                var margin = kFeatures !== null ? 30 : 4;
		var size = $(this).prop('width');

                // if the div already exists but the selected region of the image needs to be updaated, just remove the div and then create it again
		if ($('#region_'+ cIndex[4], this.el).length) {
                   $('#region_'+ cIndex[4], this.el).remove();
                }

                // create a div for the svg paper
                var paper_container = $('<div></div>').prop("id", "region_" + cIndex[4]);
                $(this).parent().append(paper_container);


		var divwidth = parseInt($(this).prop('width'), 10) + 10 + 2 * margin;
                $('#region_' + cIndex[4], this.el).prop('width', divwidth);

		if (!$.browser.webkit) { this.style.display = "none"; }

                var paper = raphael('region_' + cIndex[4], size + margin * 2, size + margin * 2);
                paper.image($(this).attr('src'), margin, margin, $(this).prop('width'), $(this).prop('height'));

                var fudge = $.browser.msie ? 1 : 0; // make sure centred in ie
                //console.log('ID '  + $(this).attr('id') );

                if (ifcirc === 0) {
                  paper.pieChart(this.width / 2 + margin - fudge, this.height / 2 + margin - fudge, this.width / 2, "#fff", $(paper_container), bp[2], reg_type[1], cIndex[4], margin, resized);
                } else {
                  paper.pieChartCirc(this.width / 2 + margin - fudge, this.height / 2 + margin - fudge, this.width / 2, "#fff", $(paper_container), bp[2], reg_type[1], cIndex[4], margin, resized);

                }

		//karyoFeatures BOF
                if (kFeatures !== null) {
                    o.features = kFeatures[5].split(',');
                    o.featureLinks = typeof(kFeatures[6]) === 'undefined' ? [] : kFeatures[6].split(',');
                    o.regionLength = bp[2];
                    o.isCircular = ifcirc === 0 ? false : true; // expects boolean type
                    paper.karyoFeatures(o, margin, size);

                }
                //karyoFeatures EOF
                
              }); //.load
            });
        }

        if ($('span.labelImg', this.el).length) {

            if (resized === 0) {
                $('span.labelImg', this.el).bind('mouseover', function () {
                    $('div.labelDiv', this.el).css('visibility', function (i, val) {
                        return 'visible';
                    });
                });
                $('span.labelImg', this.el).bind('mouseout', function () {
                    $('div.labelDiv', this.el).css('visibility', function (i, val) {
                        return 'hidden';
                    });
                });
            }
        }
    
    } 
});


Ensembl.Panel.KaryoFeaturesPanel = Ensembl.Panel.extend({
    init: function () {
        this.base();
        
        if ($('img.karyoFeatures', this.el).length) {
          var raphael = Raphael.ninja();
        }

        $('img.karyoFeatures', this.el).each(function (index) {

            // unpack the args from the id
            var args = $(this).prop('id').split('~');
            var region = args[0];

            var opts = {
                regionLength: args[1],
                isCircular: args[2] === 0 ? false : true,
                // expects boolean type
                features: args[3].split(','),
                featureLinks: typeof(args[4]) === 'undefined' ? [] : args[4].split(',') //optional
            };

            // dimensions
            var margin = 25;
            var size = $(this).prop('width');

            // create a div for the svg paper
            var containerId = "region_" + index;
            var container = $('<div></div>').prop("id", containerId);
            $(this).parent().append(container);
            $('#' + containerId, this.el).prop('width', parseInt($(this).prop('width'), 10) + 10 + 2 * margin);

            // create paper
            var paper = raphael(containerId, size + margin * 2, size + margin * 2);
            paper.image($(this).prop('src'), margin, margin, $(this).prop('width'), $(this).prop('height'));

            this.style.display = "none";

            // attach features
            paper.karyoFeatures(opts, margin, size);

        });
    }
});

