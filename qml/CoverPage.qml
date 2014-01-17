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
    Timer {
        id: pageTimer
        interval: 1000;
        running: true;
        repeat: true
        onTriggered: {
            coverCurText.text = hunger.avg_text(app.cur_time)
            coverAvgText.text = hunger.avg_text(app.avg_time)
            interval = app.cur_time * 1000
        }
    }
    Column {
        anchors.centerIn: parent
        spacing: Theme.paddingLarge
        Label {
            text: qsTr("New:")
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeLarge
        }
        Label {
            id: coverCurText
            text: ""
            font.pixelSize: Theme.fontSizeExtraLarge
        }
        Label {
            text: qsTr("Avg.:")
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeLarge
        }
        Label {
            id: coverAvgText
            text: ""
            font.pixelSize: Theme.fontSizeExtraLarge
        }
    }
}
