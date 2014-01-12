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
            text: qsTr("Now:")
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
