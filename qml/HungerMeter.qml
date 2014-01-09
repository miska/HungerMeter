import QtQuick 2.0
import Hunger 1.0
import Sailfish.Silica 1.0

ApplicationWindow
{
    Hunger {
        id: hunger
    }
    Timer {
        id: refTimer
        interval: 100;
        running: true;
        repeat: true
        onTriggered: hunger.refresh()
    }
    initialPage: Qt.resolvedUrl("FirstPage.qml")
    cover: Qt.resolvedUrl("CoverPage.qml")
}


