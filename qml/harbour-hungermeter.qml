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
import harbour.hungermeter.hunger 1.0
import harbour.hungermeter.settings 1.0
import Sailfish.Silica 1.0

ApplicationWindow
{
    id: app
    property int avg_time:  settings.value("avg_time",   10)
    property int cur_time:  settings.value("cur_time",    1)
    property int read_time: settings.value("read_time", 200)
    property int long_time: settings.value("long_time",   5)
    property int long_avg:  settings.value("long_avg",   24)
    property bool show_int: settings.value("show_int",    1)>0
    property bool percOnCover: settings.value("percOnCover",    1)>0
    Hunger {
        id: hunger
    }
    Settings {
        id: settings
    }
    Timer {
        id: refTimer
        interval: read_time;
        running: true;
        repeat: true
        onTriggered: {
            hunger.refresh(avg_time);
        }
    }
    Timer {
        id: longTimer
        // Loging mechanism checks whether action is needed,
        // but we need to make sure it is tested frequent enough
        interval: 5000;
        running: true;
        repeat: true
        onTriggered: {
            hunger.long_iter();
        }
    }
    initialPage: Qt.resolvedUrl("Consumption.qml")
    cover: Qt.resolvedUrl("CoverPage.qml")
}

