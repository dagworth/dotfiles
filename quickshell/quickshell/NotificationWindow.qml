import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root

    anchors.bottom: true
    anchors.right: true

    Layout.alignment: Qt.AlignTop
    Layout.topMargin: 20

    implicitHeight: 500
    implicitWidth: 450
    color: "transparent"
    visible: true 
    

    NotificationManager {
        anchors.fill: parent
        anchors.margins: 10
    }
}