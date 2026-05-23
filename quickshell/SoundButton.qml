import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: soundButton
    color: active ? mainColor : secondaryColor
    height: 45
    width: 45
    radius: 10

    property bool active: true

    Text {
        anchors.centerIn: parent
        text: ""
        color: mainTextColor
        font.family: custom_font.name
        font.pixelSize: 32
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            soundButton.active = !soundButton.active;
        }
    }
}