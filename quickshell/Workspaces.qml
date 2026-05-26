import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris

Rectangle {
    color: backgroundColor
    radius: 12
    Layout.preferredHeight: 60
    Layout.alignment: Qt.AlignTop
    Layout.topMargin: 15
    width: 285

    function getIcon(className) {
        console.log(className)
        let cls = className.toLowerCase();
        if (cls.includes("firefox")) return "󰈹";
        if (cls.includes("spotify")) return "󰓇";
        if (cls.includes("discord") || cls.includes("vesktop")) return "󰙯";
        if (cls.includes("foot") || cls.includes("kitty") || cls.includes("alacritty")) return "󰞷";
        if (cls.includes("thunar") || cls.includes("nautilus")) return "󰉋";
        if (cls.includes("code")) return "󰨞";
        
        return "󰣇";
    }

    Row {
        id: wsLayout
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: 5

            delegate: Rectangle {
                property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.name === (index + 1).toString()
                height: 40
                width: isActive ? 60 : 40
                radius: 12
                color: isActive ? mainColor : secondaryColor

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 0
                    anchors.verticalCenterOffset: .5
                    text: {
                        // let current = Hyprland.toplevels
                        // console.log(Hyprland.toplevels.values)

                        //return getIcon(current);
                        return ""
                    }
                    font.pixelSize: 25
                    color: isActive ? darkColor : mainTextColor
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