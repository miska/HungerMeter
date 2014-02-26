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
    property var applicationActive: app.applicationActive && status == PageStatus.Active
    function refresh() {
        curText.text = hunger.avg_text(app.cur_time)
        avgText.text = hunger.avg_text(app.avg_time)
        pageTimer.interval = app.cur_time * 1000
        canvas.array = hunger.graph(app.avg_time)
        canvas.requestPaint()
    }
    onApplicationActiveChanged: { if(applicationActive) { consumption.refresh(); } }
    onStatusChanged: { if(status == PageStatus.Active) { pageStack.pushAttached(Qt.resolvedUrl("Battery.qml")); } }
    SilicaFlickable {
        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                text: "Current ~ 3s"
                onClicked: app.cur_time = 3
            }
            MenuItem {
                text: "Current ~ 2s"
                onClicked: app.cur_time = 2
            }
            MenuItem {
                text: "Current ~ 1s"
                onClicked: app.cur_time = 1
            }
        }
        PushUpMenu {
            MenuItem {
                text: "Average ~ 5s"
                onClicked: app.avg_time = 5
            }
            MenuItem {
                text: "Average ~ 10s"
                onClicked: app.avg_time = 10
            }
            MenuItem {
                text: "Average ~ 20s"
                onClicked: app.avg_time = 20
            }
            MenuItem {
                text: "Average ~ 30s"
                onClicked: app.avg_time = 30
            }
            MenuItem {
                text: "Average ~ 60s"
                onClicked: app.avg_time = 60
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

            spacing: Theme.paddingLarge
            PageHeader {
                id: header
                title: "Consumption"
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                Rectangle {
                    width: 1
                    color: "transparent"
                    height: curText.height
                }
                Label {
                    text: qsTr("Current: ")
                    width: parent.width - curText.width - (3 * parent.spacing) - 1
                    font.pixelSize: Theme.fontSizeExtraLarge
                }
                Label {
                    id: curText
                    text: ""
                    font.pixelSize: Theme.fontSizeExtraLarge
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                Rectangle {
                    width: 1
                    color: "transparent"
                    height: avgText.height
                }
                Label {
                    text: qsTr("Average: ")
                    width: parent.width - avgText.width - (3 * parent.spacing) - 1
                    font.pixelSize: Theme.fontSizeExtraLarge
                }
                Label {
                    id: avgText
                    text: ""
                    font.pixelSize: Theme.fontSizeExtraLarge
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                Rectangle {
                    width: 1
                    color: "transparent"
                    height: canvas.height
                }
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
                    property variant array: [ 0.0, 0.0 ]
                    onPaint: {
                        var ctx = getContext("2d")
                        var step_x = canvas.width / ( array.length -1 )
                        var min = 0.0
                        var max = 0.2
                        var diff = 0
                        var min_i
                        var max_i
                        ctx.save()
                        clear(ctx)
                        ctx.font= ""
                        // Get y-range
                        for(var i = 0; i < array.length; i++) {
                            if(array[i] < min) {
                                min = array[i]
                            }
                            if(array[i] > max) {
                                max = array[i]
                            }
                        }
                        // Nicer y-range
                        // Some grid for nothing
                        if(max<0.5 && min==0.0)
                            max+=0.5
                        // Show upper bar when above X.5
                        if(Math.round(max) != Math.floor(max)) {
                            max++
                            diff = -0.5
                        }
                        min_i = Math.floor(min)
                        max_i = Math.ceil(max)
                        diff = diff + max_i - min_i
                        // Draw a grid
                        for(var i = min_i ; i<max; i++) {
                            if( i != 0) {
                                ctx.strokeStyle = Theme.secondaryHighlightColor
                                ctx.fillStyle = Theme.secondaryHighlightColor;
                            } else {
                                ctx.strokeStyle = Theme.secondaryColor
                                ctx.fillStyle = Theme.secondaryColor;
                            }
                            canvas.drawLine(ctx, 0, canvas.height - ((i - min_i) /diff ) * canvas.height, canvas.width, canvas.height - ((i - min_i)/diff) * canvas.height)
                            ctx.fillText(i + " W",diff,canvas.height - ((i - min_i) /diff ) * canvas.height - 5)
                            ctx.fillText(i + " W",canvas.width - 60 - ((i<0)?10:0),canvas.height - ((i - min_i) /diff ) * canvas.height - 5)
                        }
                        // Draw data
                        ctx.strokeStyle = Theme.primaryColor
                        for(var i = 1; i < array.length; i++) {
                            canvas.drawLine(ctx, (i-1) * step_x, canvas.height - ((array[i-1] -min_i) / diff) * canvas.height, i * step_x, canvas.height - ((array[i] - min_i)/diff) * canvas.height)
                        }
                        ctx.restore()
                    }
                }
            }
        }
    }
}
