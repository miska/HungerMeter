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
   id: about
   SilicaFlickable {
       anchors.fill: parent
       Column {
           id: column
           width: parent.width
           height: parent.height

           spacing: Theme.paddingMedium
           PageHeader {
               id: header
               title: qsTr("About")
           }
           Row {
               x: Math.min(about.width/4, about.height/4)
               Image {
                   id: about_img
                   width: Math.min(about.width/2, about.height/2)
                   height: width
                   source: "/usr/share/harbour-hungermeter/icons/about-icon.png"
               }
           }

           Row {
               width: parent.width - 2*Theme.paddingLarge
               x: Theme.paddingLarge
               Text {
                   color: Theme.primaryColor
                   width: parent.width
                   wrapMode: Text.Wrap
                   text: qsTr("<p>" + "Hunger Meter is SailfishOS application to monitor battery usage." + " " +
                              "It is distributed under GPL 3.0 and sources are available on Github." +
                              "</p><br/><p>" + "It was developed by Michal Hrušecký in 2014 to monitor battery usage on his phone." +
                              "</p>")
               }
           }
           Row {
               width: parent.width - 2*Theme.paddingMedium
               TextArea {
                   color: Theme.highlightColor
                   onClicked: Qt.openUrlExternally("http://github.com/miska/HungerMeter");
                   width: parent.width
                   readOnly: true
                   font.underline: true
                   wrapMode: Text.NoWrap
                   text: "http://github.com/miska/HungerMeter"
               }
           }
       }
   }
}
