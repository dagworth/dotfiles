import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: powerRoot
    color: secondaryColor
    radius: 10
    Layout.preferredHeight: 45
    Layout.preferredWidth: 45

    property string currentProfile: "balanced"

    function getIcon() {
        if (currentProfile === "performance") return "󱐋";
        if (currentProfile === "power-saver") return "";
        return "";
    }

    function getColor() {
        if (currentProfile === "performance") return "#f38ba8";
        if (currentProfile === "power-saver") return "#a6e3a1";
        return "#89b4fa";
    }

    Text {
        anchors.centerIn: parent
        text: powerRoot.getIcon()
        color: powerRoot.getColor()
        font.pixelSize: 30
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            let nextProfile = "balanced";
            if (powerRoot.currentProfile === "balanced") nextProfile = "power-saver";
            else if (powerRoot.currentProfile === "power-saver") nextProfile = "performance";
            else if (powerRoot.currentProfile === "performance") nextProfile = "balanced";

            setProfileCmd.command = ["powerprofilesctl", "set", nextProfile];
            setProfileCmd.running = true;

            powerRoot.currentProfile = nextProfile;
        }
    }

    Process {
        id: fetchProfileCmd
        command: ["powerprofilesctl", "get"]
        stdout: SplitParser {
            onRead: (line) => {
                let profile = line.trim();
                if (profile !== "") {
                    powerRoot.currentProfile = profile;
                }
            }
        }
    }
    Process {
        id: setProfileCmd
    }

    Timer {
        interval: 5001
        running: true
        repeat: true
        onTriggered: fetchProfileCmd.running = true
        Component.onCompleted: fetchProfileCmd.running = true
    }
}