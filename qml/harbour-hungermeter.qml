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
import Hunger 1.0
import Sailfish.Silica 1.0

ApplicationWindow
{
    id: app
    property int avg_time: 10
    property int cur_time: 1
    Hunger {
        id: hunger
    }
    Timer {
        id: refTimer
        interval: 200;
        running: true;
        repeat: true
        onTriggered: {
            hunger.refresh(avg_time)
            interval = 200 * (cur_time/2)
        }
    }
    initialPage: Qt.resolvedUrl("FirstPage.qml")
    cover: Qt.resolvedUrl("CoverPage.qml")
}

