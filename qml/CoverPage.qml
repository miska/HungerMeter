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

    function percentageOrNot(onCoverBool) {
        if(onCoverBool) {
            coverPercentageOrNot.text = hunger.bat_cur_pr()
        } else {
            coverPercentageOrNot.text = hunger.long_text()
        }
    }

    Timer {
        id: pageTimer
        interval: 1000;
        running: true;
        repeat: true
        onTriggered: {
            coverCurText.text = hunger.avg_text(app.cur_time)
            coverAvgText.text = hunger.avg_text(app.avg_time)
            coverPage.percentageOrNot(percOnCover)
            interval = app.cur_time * 1000
        }
    }
    Column {
        x: Theme.paddingLarge
        y: Theme.paddingMedium
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
            font.pixelSize: Theme.fontSizeLarge
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
            font.pixelSize: Theme.fontSizeLarge
        }

        Label {
            text: {
                if(percOnCover == false) {
                    (app.show_int?"":qsTr("Long ")) + qsTr("Avg") + (app.show_int?(" (" + app.long_avg + " h):"):":")
                } else {
                    "Battery:"
                }
            }
            width: parent.width
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            id: coverPercentageOrNot
            width: parent.width
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeLarge
        }
    }
}
