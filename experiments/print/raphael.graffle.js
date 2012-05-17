/**
 * Originally grabbed from the official RaphaelJS Documentation
 * http://raphaeljs.com/graffle.html
 * Adopted (arrows) and commented by Philipp Strathausen http://blog.ameisenbar.de
 * Licenced under the MIT licence.
 */

/**
 * Usage:
 * connect two shapes
 * parameters:
 *      source shape [or connection for redrawing],
 *      target shape,
 *      style with { fg : linecolor, bg : background color, directed: boolean }
 * returns:
 *      connection { draw = function() }
 */
Raphael.fn.connection = function Connection(obj1, obj2, style) {
    var selfRef = this;
    /* create and return new connection */
    var edge = {/*
                  from : obj1,
                  to : obj2,
                  style : style,*/
        draw : function() {
            // var bb1 = obj1.getBBox();
            // var bb2 = obj2.getBBox();
            // var off1 = 0;
            // var off2 = 0;
            // /* coordinates for potential connection coordinates from/to the objects */
            // var p = [
            //     /* NORTH 1 */
            //     { x: bb1.x + bb1.width / 2, y: bb1.y - off1 },
            //     /* SOUTH 1 */
            //     { x: bb1.x + bb1.width / 2, y: bb1.y + bb1.height + off1 },
            //     /* WEST */
            //     { x: bb1.x - off1, y: bb1.y + bb1.height / 2 },
            //     /* EAST  1 */
            //     { x: bb1.x + bb1.width + off1, y: bb1.y + bb1.height / 2 },
            //     /* NORTH 2 */
            //     { x: bb2.x + bb2.width / 2, y: bb2.y - off2 },
            //     /* SOUTH 2 */
            //     { x: bb2.x + bb2.width / 2, y: bb2.y + bb2.height + off2 },
            //     /* WEST  2 */
            //     { x: bb2.x - off2, y: bb2.y + bb2.height / 2 },
            //     /* EAST  2 */
            //     { x: bb2.x + bb2.width + off2, y: bb2.y + bb2.height / 2 }
            // ];
            // /* distances between objects and according coordinates connection */
            // var d = {}, dis = [];
            
            // /*
            //  * find out the best connection coordinates by trying all possible ways
            //  */
            // /* loop the first object's connection coordinates */
            // for (var i = 0; i < 4; i++) {
            //     /* loop the second object's connection coordinates */
            //     for (var j = 4; j < 8; j++) {
            //         var dx = Math.abs(p[i].x - p[j].x);
            //         var dy = Math.abs(p[i].y - p[j].y);
            //         if ((i == j - 4) || (((i != 3 && j != 6) || p[i].x < p[j].x)
            //                              && ((i != 2 && j != 7) || p[i].x > p[j].x)
            //                              && ((i != 0 && j != 5) || p[i].y > p[j].y)
            //                              && ((i != 1 && j != 4) || p[i].y < p[j].y)))
            //         {
            //             dis.push(dx + dy);
            //             d[dis[dis.length - 1].toFixed(3)] = [i, j];
            //         }
            //     }
            // }
            // var res = dis.length == 0 ? [0, 4] : d[Math.min.apply(Math, dis).toFixed(3)];
            // var x1 = p[res[0]].x,
            // y1 = p[res[0]].y,
            // x2 = p[res[1]].x,
            // y2 = p[res[1]].y;
            
            var bb1 = obj1[0].getBBox();
            var bb2 = obj2[0].getBBox();

            var x1 = bb1.x + bb1.width/2,
            y1 = bb1.y + bb1.height/2,
            x2 = bb2.x + bb2.width/2,
            y2 = bb2.y + bb2.height/2;
            
            console.log(bb1);
            
            /* get bounding boxes of target and source */
            /* assemble path and arrow */
            var path = [ "M" + x1.toFixed(3), y1.toFixed(3), "L" + x2.toFixed(3), y2.toFixed(3)].join(",");
            
            /* function to be used for moving existent path(s), e.g. animate() or attr() */
            var move = "attr";
            /* applying path(s) */
            edge.fg && edge.fg[move]({path:path})
                || (edge.fg = selfRef.path(path)
                    .attr({ stroke: style && style.stroke || "#000", fill: "none" })
                    .toBack());
            edge.bg && edge.bg[move]({path:path})
                || style && style.fill && (edge.bg = style.fill.split
                                           && selfRef.path(path)
                                           .attr({ stroke: style.fill.split("|")[0], fill: "none",
                                                   "stroke-width": style.fill.split("|")[1] || 3 }).toBack());
            /* setting label */
            style && style.label
                && (edge.label && edge.label.attr({x:(x1+x4)/2, y:(y1+y4)/2})
                    || (edge.label = selfRef.text((x1+x4)/2, (y1+y4)/2, style.label)
                        .attr({fill: "#000", "font-size": style["font-size"] || "12px"})));
            style && style.label && style["label-style"] && edge.label
                && edge.label.attr(style["label-style"]);
            style && style.callback && style.callback(edge);
        }
    }
    edge.draw();
    return edge;
};
