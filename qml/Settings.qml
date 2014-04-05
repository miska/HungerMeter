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
    id: sets
    property var applicationActive: app.applicationActive && status == (status == PageStatus.Active || status == PageStatus.Activating)
    onApplicationActiveChanged: { if(applicationActive) refresh(); }
    function refresh() {
        var i
        for (i = 0; i < shortMenu.short_values.length; ++i) {
            if(app.cur_time == shortMenu.short_values[i])
                curCombo.currentIndex = i
        }
        for (i = 0; i < avgMenu.avg_values.length; ++i) {
            if(app.avg_time == avgMenu.avg_values[i])
                avgCombo.currentIndex = i
        }
        for (i = 0; i < readMenu.read_values.length; ++i) {
            if(app.read_time == readMenu.read_values[i])
                readCombo.currentIndex = i
        }
        for (i = 0; i < longAvgMenu.long_avg_values.length; ++i) {
            if(app.long_avg == longAvgMenu.long_avg_values[i])
                longAvgCombo.currentIndex = i
        }
        for (i = 0; i < longMenu.long_values.length; ++i) {
            if(app.long_time == longMenu.long_values[i])
                longCombo.currentIndex = i
        }
        showInterval.checked = settings.value("show_int", 1) > 0;
        persistent.checked = settings.value("persistent", 0) > 0;
        battery_first.checked = settings.value("battery_first", 0) > 0;
    }
    SilicaFlickable {
        anchors.fill: parent
        Column {
            id: column
            width: parent.width - 2*x
            x: Theme.paddingSmall

            spacing: Theme.paddingSmall
            PageHeader {
                id: header
                title: qsTr("Settings")
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                ComboBox {
                    id: curCombo
                    width: sets.width - parent.spacing * 2
                    label: qsTr("Short interval: ")

                    menu: ContextMenu {
                        id: shortMenu
                        property var short_values: [1, 2, 3, 5];
                        onActivated: { app.cur_time = short_values[index]; settings.setValue("cur_time", short_values[index]); }
                        MenuItem { text: "" + shortMenu.short_values[0] + " s"; }
                        MenuItem { text: "" + shortMenu.short_values[1] + " s"; }
                        MenuItem { text: "" + shortMenu.short_values[2] + " s"; }
                        MenuItem { text: "" + shortMenu.short_values[3] + " s"; }
                    }
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                ComboBox {
                    id: avgCombo
                    width: sets.width - parent.spacing * 2
                    label: qsTr("Short average interval: ")

                    menu: ContextMenu {
                        id: avgMenu
                        property var avg_values: [10, 20, 30, 40, 50, 60];
                        onActivated: { app.avg_time = avg_values[index]; settings.setValue("avg_time", avg_values[index]); }
                        MenuItem { text: "" + avgMenu.avg_values[0] + " s"; }
                        MenuItem { text: "" + avgMenu.avg_values[1] + " s"; }
                        MenuItem { text: "" + avgMenu.avg_values[2] + " s"; }
                        MenuItem { text: "" + avgMenu.avg_values[3] + " s"; }
                        MenuItem { text: "" + avgMenu.avg_values[4] + " s"; }
                        MenuItem { text: "" + avgMenu.avg_values[5] + " s"; }
                    }
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                ComboBox {
                    id: longAvgCombo
                    width: sets.width - parent.spacing * 2
                    label: qsTr("Long average interval: ")

                    menu: ContextMenu {
                        id: longAvgMenu
                        property var long_avg_values: [12, 24, 48, 72, 120, 168];
                        onActivated: { app.long_avg = long_avg_values[index]; settings.setValue("long_avg", long_avg_values[index]); }
                        MenuItem { text: "" + longAvgMenu.long_avg_values[0] + " h"; }
                        MenuItem { text: "" + longAvgMenu.long_avg_values[1] + " h"; }
                        MenuItem { text: "" + longAvgMenu.long_avg_values[2] + " h"; }
                        MenuItem { text: "" + longAvgMenu.long_avg_values[3] + " h"; }
                        MenuItem { text: "" + longAvgMenu.long_avg_values[4] + " h"; }
                        MenuItem { text: "" + longAvgMenu.long_avg_values[5] + " h"; }
                    }
                }
            }
            TextSwitch {
                id: showInterval
                text: qsTr("Display time intervals")
                checked: app.show_int
                onCheckedChanged: {
                    app.show_int = checked
                    settings.setValue("show_int", checked?1:0);
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                ComboBox {
                    id: readCombo
                    width: sets.width - parent.spacing * 2
                    label: qsTr("Sampling interval: ")

                    menu: ContextMenu {
                        id: readMenu
                        property var read_values: [ 200, 250, 500, 750 ];
                        onActivated: { app.read_time = read_values[index]; settings.setValue("read_time", read_values[index]); }
                        MenuItem { text: "" + readMenu.read_values[0] + " ms"; }
                        MenuItem { text: "" + readMenu.read_values[1] + " ms"; }
                        MenuItem { text: "" + readMenu.read_values[2] + " ms"; }
                        MenuItem { text: "" + readMenu.read_values[3] + " ms"; }
                    }
                }
            }
            Row {
                width: parent.width
                spacing: parent.spacing
                ComboBox {
                    id: longCombo
                    width: sets.width - parent.spacing * 2
                    label: qsTr("Long sampling interval: ")

                    menu: ContextMenu {
                        id: longMenu
                        property var long_values: [5, 10, 30, 60];
                        onActivated: { app.long_time = long_values[index]; settings.setValue("long_time", long_values[index]); }
                        MenuItem { text: "" + longMenu.long_values[0] + " min"; }
                        MenuItem { text: "" + longMenu.long_values[1] + " min"; }
                        MenuItem { text: "" + longMenu.long_values[2] + " min"; }
                        MenuItem { text: "" + longMenu.long_values[3] + " min"; }
                    }
                }
            }
            TextSwitch {
                id: persistent
                text: qsTr("Persistent storage")
                checked: settings.value("persistent", 0) > 0
                description: qsTr("Wears down you flash, but keeps data accross reboots.")
                onCheckedChanged: {
                    settings.setValue("persistent", checked?1:0);
                }
            }
            TextSwitch {
                id: battery_first
                text: qsTr("Battery firts on cover")
                description: qsTr("Show battery info on the app cover on start.")
                onCheckedChanged: {
                    settings.setValue("battery_first", checked?1:0);
                }
            }
        }
    }
}
