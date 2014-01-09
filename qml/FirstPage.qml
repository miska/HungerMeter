import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    Timer {
        id: pageTimer
        interval: 1000;
        running: true;
        repeat: true
        onTriggered: { curText.text = hunger.current_text(pageTimer.interval/refTimer.interval); avgText.text = hunger.avg_text() }
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
                text: hunger.current_text(pageTimer.interval/refTimer.interval)
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
                text: hunger.avg_text()
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
}
