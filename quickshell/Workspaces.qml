import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris

Rectangle {
    color: backgroundColor
    radius: 5
    Layout.preferredHeight: 30
    Layout.alignment: Qt.AlignTop
    Layout.topMargin: 6
    width: 150

    Row {
        id: wsLayout
        anchors.centerIn: parent
        spacing: 7

        Repeater {
            model: 5

            delegate: Rectangle {
                property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.name === (index + 1).toString()
                height: 20
                width: isActive ? 28 : 20
                radius: 5
                color: isActive ? '#f5c2e7' : '#45475a'

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: -.5
                    anchors.verticalCenterOffset: .5
                    text: [" ", "󰈹", " ", "󰓇", "󰙯"][index]
                    font.pixelSize: 13
                    font.bold: true
                    color: isActive ? "#1e141e" : "#cdd6f4"
                }

                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + (index+1) + '" })')
                }
            }
        }
    }
}