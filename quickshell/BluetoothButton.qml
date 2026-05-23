import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Rectangle {
    id: bluetoothButton
    color: active ? mainColor : secondaryColor
    height: 45
    width: 45
    radius: 10

    property bool active: false

    Text {
        anchors.centerIn: parent
        text: "󰂯"
        color: mainTextColor
        font.family: custom_font.name
        font.pixelSize: 32
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            bluetoothButton.active = !bluetoothButton.active;
        }
    }

    PanelWindow {
        implicitHeight: 500
        implicitWidth: 450
        color: "transparent"
        visible: active
        anchors.top: true
        anchors.right: true
        Bluetooth {}
    }
}