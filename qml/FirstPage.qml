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
        }
    }
}
