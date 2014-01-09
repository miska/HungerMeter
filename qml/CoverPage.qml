import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Timer {
        interval: 1000;
        running: true;
        repeat: true
        onTriggered: { coverText.text = hunger.current_text(10); coverAvgText.text = hunger.avg_text() }
    }
    Column {
        anchors.centerIn: parent
        spacing: Theme.paddingLarge
        Label {
            text: qsTr("Now:")
            font.pixelSize: Theme.fontSizeLarge
        }
        Label {
            id: coverText
            text: hunger.current_text(10)
            font.pixelSize: Theme.fontSizeExtraLarge
        }
        Label {
            text: qsTr("Avg.:")
            font.pixelSize: Theme.fontSizeLarge
        }
        Label {
            id: coverAvgText
            text: hunger.avg_text()
            font.pixelSize: Theme.fontSizeExtraLarge
        }
    }
}
