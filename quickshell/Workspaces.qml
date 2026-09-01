import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris

Rectangle {
    color: backgroundColor
    radius: bubbleRadius
    height: bubbleHeight
    Layout.alignment: Qt.AlignTop
    Layout.topMargin: bubbleTopMargin
    Layout.preferredWidth: workspaces.implicitWidth + 24

    property int closeHeight: bubbleHeight*2/3
    property var iconPriority: [
        { name: "burp-StartBurp", icon: "󰀂" },
        { name: "discord", icon: "󰙯" },
        { name: "Spotify", icon: "󰓇" },
        { name: "godotengine", icon: "" },
        { name: "steam", icon: "" },
        { name: "qbittorrent", icon: "󰨈" },
        { name: "code-oss", icon: "󰨞" },
        { name: "firefox", icon: "󰈹" },
        { name: "vlc", icon: "" },
        { name: "kitty", icon: "󰞷" },
    ]

    function getIcon(win) {
        let name = win.wayland.appId
        let title = win.title
        if (!name) return "";
        if (name.includes("kitty")) {
            if (title.includes("notes")) return "󰠮";
            if (title.includes("Yazi")) return "";
            return "󰞷";
        }
        for (let i = 0; i < iconPriority.length; i++) {
            if (name.includes(iconPriority[i].name)) return iconPriority[i].icon;
        }
        return "";
    }

    function getIconPriority(win) {
        let name = win.wayland.appId
        if (!name) return iconPriority.length;
        for (let i = 0; i < iconPriority.length; i++) {
            if (name.includes(iconPriority[i].name)) return i;
        }
        return iconPriority.length;
    }

    function getIconForWorkspace(workspaceName) {
        let windows = Hyprland.toplevels.values;
        let final = "";
        let highest = iconPriority.length + 1;

        for (let i = 0; i < windows.length; i++) {
            let win = windows[i];
            if (win.workspace && win.workspace.name === workspaceName) {
                let p = getIconPriority(win);
                if (p < highest) {
                    highest = p;
                    final = getIcon(win);
                }
            }
        }
        return final;
    }

    function getWorkspacesModel() {
        let defaultws = [1, 2, 3, 4, 5];
        let windows = Hyprland.toplevels.values;

        for (let i = 0; i < windows.length; i++) {
            let win = windows[i];
            if (win.workspace) {
                let a = parseInt(win.workspace.name);
                if (a > 5 && !defaultws.includes(a)) {
                    defaultws.push(a);
                }
            }
        }
        return defaultws.sort((a, b) => a - b);
    }

    Row {
        id: workspaces
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: getWorkspacesModel(Hyprland.toplevels.values)

            delegate: Rectangle {
                property string workspace: modelData.toString()
                property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.name === workspace

                height: closeHeight
                width: isActive ? bubbleHeight : closeHeight
                radius: bubbleRadius
                color: isActive ? mainColor : secondaryColor

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 0
                    anchors.verticalCenterOffset: .5
                    text: getIconForWorkspace(workspace)
                    font.pixelSize: bubbleHeight*.4
                    color: isActive ? darkColor : mainTextColor
                }

                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + workspace + '" })')
                }
            }
        }
    }
}
