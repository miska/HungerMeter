/******************************************************************************
 *                                                                            *
 * HungerMeter - consumption measuring tool for SailfishOS                    *
 * Copyright (C) 2014 by Michal Hrusecky <Michal@Hrusecky.net>                *
 *                                                                            *
 * This program is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation, either version 3 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 *                                                                            *
 ******************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: consumption
    allowedOrientations: Orientation.All
    property var applicationActive: app.applicationActive && (status == PageStatus.Active || status == PageStatus.Activating)
    function refresh() {
        curText.text = hunger.avg_text(app.cur_time);
        avgText.text = hunger.avg_text(app.avg_time);
        longText.text = hunger.long_text();
        pageTimer.interval = app.cur_time * 1000;
        var now_t = Math.round(Date.now()/300000);
        if(!show_long_term || last_long_refresh < now_t) {
            canvas.array = show_long_term ? hunger.long_graph(app.long_avg * 3600) : hunger.graph(app.avg_time);
            canvas.requestPaint();
            if(show_long_term)
                last_long_refresh = now_t;
        }
    }
    property var show_long_term: false;
    property var last_long_refresh: 0;
    onApplicationActiveChanged: { if(applicationActive) { consumption.refresh(); } }
    onStatusChanged: { if((status == PageStatus.Active) && (!app.battery)) { pageStack.pushAttached(Qt.resolvedUrl("Battery.qml")); } }
    SilicaFlickable {
        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
        }
        PushUpMenu {
            MenuItem {
                text: show_long_term ? qsTr("Short term graph") : qsTr("Long term graph")
                onClicked: { canvas.clear(canvas.getContext("2d")); show_long_term = !show_long_term; if(show_long_term) last_long_refresh = 0; consumption.refresh(); }
            }
        }

        Timer {
            id: pageTimer
            interval: 1000;
            running: applicationActive
            repeat: true
            onTriggered: consumption.refresh()
        }
        Column {
            id: column
            width: parent.width
            height: parent.height

            spacing: Theme.paddingMedium
            PageHeader {
                id: header
                title: qsTr("Consumption")
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                x: parent.spacing
                Label {
                    text: qsTr("Current") + (app.show_int?(" (" + app.cur_time + " s):"):":")
                    width: parent.width - curText.width - (3 * parent.spacing) - 1
                    font.pixelSize: Theme.fontSizeLarge
                }
                Label {
                    id: curText
                    text: ""
                    font.pixelSize: Theme.fontSizeLarge
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                x: parent.spacing
                Label {
                    text: qsTr("Average") + (app.show_int?(" (" + app.avg_time + " s):"):":")
                    width: parent.width - avgText.width - (3 * parent.spacing) - 1
                    font.pixelSize: Theme.fontSizeLarge
                }
                Label {
                    id: avgText
                    text: ""
                    font.pixelSize: Theme.fontSizeLarge
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                x: parent.spacing
                Label {
                    text: qsTr("Average") + (app.show_int?(" (" + app.long_avg + " h):"):" (" + qsTr("longer") + "):")
                    width: parent.width - longText.width - (3 * parent.spacing) - 1
                    font.pixelSize: Theme.fontSizeLarge
                }
                Label {
                    id: longText
                    text: ""
                    font.pixelSize: Theme.fontSizeLarge
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                x: parent.spacing
                Canvas {
                    id: canvas
                    width: parent.width - 2*Theme.paddingLarge
                    height: column.height - curText.height - avgText.height - header.height - 5*Theme.paddingLarge
                    function drawLine(ctx,x1,y1,x2,y2) {
                        ctx.beginPath();
                        ctx.lineWidth = 3
                        ctx.moveTo(x1, y1);
                        ctx.lineTo(x2, y2);
                        ctx.stroke();
                        ctx.closePath();
                    }
                    function clear(ctx) {
                        ctx.clearRect(0, 0, width, height);
                    }
                    property variant array: [ [ 0.0, 0.0 ] ];
                    onPaint: {
                        var ctx = getContext("2d");
                        var px = Math.max(Math.round(canvas.height/25), Math.round(canvas.width/40));
                        ctx.save();
                        clear(ctx);

                        // Set reasonable font size
                        ctx.font = "" + px + "px Monospace";

                        // Error out early
                        if(array.length < 2) {
                            ctx.font = "" + (px + 2) + "px Monospace";
                            ctx.strokeStyle = Theme.secondaryColor;
                            ctx.fillStyle = Theme.secondaryColor;
                            var txt = qsTr("No data available!!!");
                            ctx.fillText(txt, (canvas.width - ctx.measureText(txt).width)/2, canvas.height/2 - px);
                            ctx.restore();
                            return;
                        }

                        // Initialize some variables
                        var step_x = canvas.width / ( array.length -1);
                        var min_y = 0.0;
                        var max_y = 0.2;
                        var max_x = array[0][1];
                        var min_x = array[array.length - 1][1];
                        var min_i = 0;
                        var max_i = 0;
                        var diff_y = 0;
                        var step_y = 0;
                        var max_txt = 0;
                        var diff_x = max_x - min_x;

                        // Get y-range
                        for(var i = 0; i < array.length; i++) {
                            if(array[i][0] < min_y) {
                                min_y = array[i][0];
                            }
                            if(array[i][0] > max_y) {
                                max_y = array[i][0];
                            }
                            if(array[i][1] < min_x) {
                                min_x = array[i][1];
                            }
                            if(array[i][1] > max_x) {
                                max_x = array[i][1];
                            }
                        }
                        // Nicer y-range
                        // Some grid for nothing
                        if(max_y < 0.5 && min_y == 0.0)
                            max_y += 0.5;

                        // Show upper bar when above X.5
                        if(Math.round(max_y) != Math.floor(max_y)) {
                            max_y++;
                            diff_y = -0.5;
                        }
                        min_i = Math.floor(min_y);
                        max_i = Math.ceil(max_y);
                        diff_y = diff_y + max_i - min_i;
                        step_y = Math.max(Math.floor (diff_y / 3), 1);
                        max_y = max_y + diff_y / 10;
                        diff_y += diff_y / 10;

                        // Draw a grid
                        for(var i = min_i ; i < max_y; i += step_y) {
                            if( i != 0) {
                                ctx.strokeStyle = Theme.secondaryHighlightColor;
                                ctx.fillStyle = Theme.secondaryHighlightColor;
                            } else {
                                ctx.strokeStyle = Theme.secondaryColor;
                                ctx.fillStyle = Theme.secondaryColor;
                            }
                            canvas.drawLine(ctx,
                                            0,
                                            canvas.height - ((i - min_i) / diff_y ) * canvas.height,
                                            canvas.width,
                                            canvas.height - ((i - min_i) / diff_y ) * canvas.height);
                            max_txt = Math.max(ctx.measureText(i + (consumption.show_long_term ? " Wh " : " W ")).width, max_txt);
                        }

                        function round_time(what, diff) {
                            if(diff>3600) {
                                var tmp_dat = new Date(what*1000);
                                tmp_dat.setSeconds(0);
                                if(diff>3600*24) {
                                    tmp_dat.setMinutes(0);
                                    tmp_dat.setHours(0);
                                }
                                what = Math.round(tmp_dat.getTime()/1000);
                            }
                            return what;
                        }

                        var vline1 = round_time(min_x +   diff_x/3, diff_x);
                        var vline2 = round_time(min_x + 2*diff_x/3, diff_x);
                        canvas.drawLine(ctx, (vline1 - min_x) * canvas.width / diff_x, 0, (vline1 - min_x) * canvas.width / diff_x, canvas.height);
                        canvas.drawLine(ctx, (vline2 - min_x) * canvas.width / diff_x, 0, (vline2 - min_x) * canvas.width / diff_x, canvas.height);

                        // Draw data
                        ctx.strokeStyle = Theme.primaryColor;
                        for(var i = 1; i < array.length; i++) {
                            canvas.drawLine(ctx,
                                            ((array[i-1][1] - min_x) / diff_x) * canvas.width,
                                            canvas.height - ((array[i-1][0] - min_i) / diff_y) * canvas.height,
                                            ((array[i][1]   - min_x) / diff_x) * canvas.width,
                                            canvas.height - ((array[i  ][0] - min_i) / diff_y) * canvas.height);
                        }

                        // Draw a legend
                        for(var i = min_i ; i < max_y; i += step_y) {
                            if( i != 0) {
                                ctx.strokeStyle = Theme.secondaryHighlightColor;
                                ctx.fillStyle = Theme.secondaryHighlightColor;
                            } else {
                                ctx.strokeStyle = Theme.secondaryColor;
                                ctx.fillStyle = Theme.secondaryColor;
                            }
                            var txt = i + (consumption.show_long_term ? " Wh" : " W");
                            ctx.fillText(txt, 0, canvas.height - ((i - min_i) / diff_y ) * canvas.height - px / 4);
                            ctx.fillText(txt, canvas.width - ctx.measureText(txt).width, canvas.height - ((i - min_i) / diff_y ) * canvas.height - px / 4);
                        }

                        function format_time(in_dte, diff) {
                            var dte = new Date(in_dte*1000);
                            var dow = [ qsTr("Sun"), qsTr("Mon"), qsTr("Tue"), qsTr("Wed"), qsTr("Thu"), qsTr("Fri"), qsTr("Sat")];
                            var ret = "";
                            if(diff < 3600*24) {
                               var tmp;
                               tmp = dte.getMinutes();
                               tmp = ((tmp<10)?("0"+tmp):tmp);
                               ret = "" + dte.getHours() + ":" + tmp;
                               if(diff<3600) {
                                   tmp = dte.getSeconds();
                                   tmp = ((tmp<10)?("0"+tmp):tmp);
                                   ret += ":" + tmp;
                               }
                            } else {
                               ret = dow[dte.getDay()];
                            }
                            return ret;
                        }

                        ctx.fillText(format_time(vline1, diff_x), (vline1 - min_x) * canvas.width/diff_x + px/4, px + px/4);
                        ctx.fillText(format_time(vline2, diff_x), (vline2 - min_x) * canvas.width/diff_x + px/4, px + px/4);

                        ctx.restore()
                    }
                }
            }
        }
    }
}
