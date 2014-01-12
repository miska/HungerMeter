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
            hunger.refresh()
            interval = 200 * cur_time
        }
    }
    initialPage: Qt.resolvedUrl("FirstPage.qml")
    cover: Qt.resolvedUrl("CoverPage.qml")
}

