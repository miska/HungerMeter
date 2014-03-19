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
    id: battery
    allowedOrientations: Orientation.All
    property var applicationActive: app.applicationActive && (status == PageStatus.Active || status == PageStatus.Activating)
    function refresh() {
        fullText.text = hunger.bat_full();
        curText.text  = hunger.bat_cur();
        curPrText.text  = hunger.bat_cur_pr();
        batPrIcon.width  = (batIcon.width * hunger.bat_cur_pr_val())/100;
        timeText.text = hunger.tme_left();
        timeLeft.text = qsTr("Time left till " + (hunger.charging()>0 ? "full" : "empty") + ":")
    }
    Timer {
        id: batteryTimer
        interval: app.cur_time * 1000
        running: applicationActive
        repeat: true
        onTriggered: battery.refresh()
    }
    onApplicationActiveChanged: { if(applicationActive) { battery.refresh(); } }
    SilicaFlickable {
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
        anchors.fill: parent
        Column {
            id: column
            width: parent.width
            height: parent.height

            spacing: Theme.paddingMedium
            PageHeader {
                id: header
                title: qsTr("Battery Info")
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                x: parent.spacing
                Label {
                    text: qsTr("Full: ")
                    width: parent.width - curText.width - (3 * parent.spacing) - 1
                    font.pixelSize: Theme.fontSizeLarge
                }
                Label {
                    id: fullText
                    text: "0 mWh"
                    font.pixelSize: Theme.fontSizeLarge
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                x: parent.spacing
                Label {
                    text: qsTr("Current: ")
                    width: parent.width - curText.width - (3 * parent.spacing) - 1
                    font.pixelSize: Theme.fontSizeLarge
                }
                Label {
                    id: curText
                    text: "0 mWh"
                    font.pixelSize: Theme.fontSizeLarge
                }
            }
            Item {
                width: parent.width
                height: Math.max(battery.height - 10*Theme.fontSizeLarge - 5*Theme.paddingMedium, Theme.fontSizeLarge * 3.5)
                onWidthChanged: battery.refresh()
                Rectangle {
                    id: batIcon
                    anchors.centerIn: parent
                    width: battery.width - Theme.fontSizeExtraLarge * 4
                    color: "transparent"
                    border.color: Theme.primaryColor
                    border.width: 3
                    height: parent.height / 3
                    Label {
                        anchors.centerIn: parent
                        id: curPrText
                        text: "0 %"
                        font.pixelSize: Theme.fontSizeLarge
                    }
                    Rectangle {
                        id: batPrIcon
                        width: parent.width / 2
                        height: parent.height
                        color: Theme.secondaryColor
                    }
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                x: parent.spacing
                Label {
                    id: timeLeft
                    text: qsTr("Time left till " + (hunger.charging()>0 ? "full" : "empty") + ":")
                    width: parent.width - curText.width - (3 * parent.spacing) - 1
                    font.pixelSize: Theme.fontSizeLarge
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                Label {
                    id: timeText
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Estimating")
                    font.pixelSize: Theme.fontSizeLarge
                }
            }
        }
    }
}
