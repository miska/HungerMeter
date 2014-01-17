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
    id: first
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
            running: true;
            repeat: true
            onTriggered: {
                curText.text = hunger.avg_text(app.cur_time)
                avgText.text = hunger.avg_text(app.avg_time)
                interval = app.cur_time * 1000
                canvas.array = hunger.graph(app.avg_time - 1)
                canvas.requestPaint()
            }
        }
        Column {
            id: column
            width: parent.width
            height: parent.height

            spacing: Theme.paddingLarge
            PageHeader {
                id: header
                title: "Hunger Meter"
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
                        ctx.save()
                        clear(ctx)
                        ctx.strokeStyle = Theme.secondaryColor
                        ctx.fillStyle = Theme.secondaryColor;
                        ctx.font= ""
                        for(var i = 0; i<4; i++) {
                            canvas.drawLine(ctx, 0, canvas.height - (i /4.0 ) * canvas.height, canvas.width, canvas.height - (i/4.0) * canvas.height)
                            ctx.fillText(i + " W",5,canvas.height - (i /4.0 ) * canvas.height - 5)
                            ctx.fillText(i + " W",canvas.width - 60,canvas.height - (i /4.0 ) * canvas.height - 5)
                        }
                        ctx.strokeStyle = Theme.primaryColor
                        for(var i = 1; i < array.length; i++) {
                            canvas.drawLine(ctx, (i-1) * step_x, canvas.height - (array[i-1] / 4.0) * canvas.height, i * step_x, canvas.height - (array[i]/4.0) * canvas.height)
                        }
                        ctx.restore()
                    }
                }
            }
        }
    }
}
