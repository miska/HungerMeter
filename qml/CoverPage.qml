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

CoverBackground {
    id: coverPage
    property bool bat_active: app.battery
    function refresh() {
        if(!bat_active) {
        coverCurText.text =  hunger.avg_text(app.cur_time)
        coverAvgText.text =  hunger.avg_text(app.avg_time)
        coverLongText.text = hunger.long_text()
        } else {
        coverBatPr.text =    hunger.bat_cur_pr()
        coverTmeLeft.text =  hunger.tme_left_short()
        }
        pageTimer.interval = app.cur_time * 1000
    }
    Timer {
        id: pageTimer
        interval: 1000;
        running: true;
        repeat: true
        onTriggered: coverPage.refresh()
    }
    Column {
        x: Theme.paddingMedium
        y: Theme.paddingMedium
        visible: !bat_active
        width: parent.width - 2 * Theme.paddingLarge
        spacing: Theme.paddingSmall
        Label {
            text: qsTr("Now") + (app.show_int?(" (" + app.cur_time + " s):"):":")
            width: parent.width
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            id: coverCurText
            text: ""
            width: parent.width
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            text: qsTr("Avg") + (app.show_int?(" (" + app.avg_time + " s):"):":")
            width: parent.width
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            id: coverAvgText
            width: parent.width
            horizontalAlignment: Text.AlignRight
            text: ""
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            text: (app.show_int?"":qsTr("Long ")) + qsTr("Avg") + (app.show_int?(" (" + app.long_avg + " h):"):":")
            width: parent.width
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            id: coverLongText
            width: parent.width
            horizontalAlignment: Text.AlignRight
            text: hunger.long_text()
            font.pixelSize: Theme.fontSizeMedium
        }
    }
    Column {
        x: Theme.paddingLarge
        y: Theme.paddingMedium
        visible: bat_active
        width: parent.width - 2 * Theme.paddingLarge
        spacing: Theme.paddingLarge
        Label {
            text: qsTr("Battery left:")
            width: parent.width
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            id: coverBatPr
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: ""
            font.pixelSize: Theme.fontSizeLarge
        }
        Label {
            text: qsTr("Time left:")
            width: parent.width
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            id: coverTmeLeft
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: ""
            font.pixelSize: Theme.fontSizeLarge
        }
    }
    CoverActionList {
        id: coverAction

        CoverAction {
            id: coverSwith
            iconSource: (!(app.battery^bat_active))?"image://theme/icon-cover-next":"image://theme/icon-cover-previous"
            onTriggered: {
                bat_active = !bat_active;
                refresh();
            }
        }
    }
}
