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
    Layout.preferredWidth: workspaces.implicitWidth + 24

    function getIcon(win) {
        let name = win.wayland.appId
        // console.log(name)
        if (name) {
            if (name.includes("firefox")) return "󰈹";
            if (name.includes("Spotify")) return "󰓇";
            if (name.includes("discord")) return "󰙯";
            if (name.includes("kitty")) return "󰞷";
            if (name.includes("code-oss")) return "󰨞";
            if (name.includes("obsidian")) return "";
        }
        //use win.title if not wayland
        return "";
    }

    function getIconForWorkspace(index) {
        let name = (index + 1).toString();
        let windows = Hyprland.toplevels.values;
        
        for (let i = 0; i < windows.length; i++) {
            let win = windows[i];
            if (win.workspace && win.workspace.name == name) {
                return getIcon(win);
            }
        }

        return "";
    }

    Row {
        id: workspaces
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
                    text: getIconForWorkspace(index)
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