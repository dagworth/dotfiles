import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: brightnessRoot
    color: secondaryColor
    radius: buttonRadius
    height: buttonHeight
    width: buttonHeight

    Layout.alignment: Qt.AlignTop
    Layout.topMargin: buttonTopMargin

    property int currentLevel: 100

    function getIcon() {
        if (currentLevel === 100) return "󰌵";
        if (currentLevel === 50) return "󱠂";
        return "󱩌";
    }

    function getColor() {
        if (currentLevel === 100) return "#f9e2af";
        if (currentLevel === 50) return "#fab387";
        return '#5763be';
    }

    Text {
        anchors.centerIn: parent
        text: brightnessRoot.getIcon()
        color: brightnessRoot.getColor()
        font.pixelSize: 30
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            let nextLevel = 100;
            if (brightnessRoot.currentLevel === 100) nextLevel = 50;
            else if (brightnessRoot.currentLevel === 50) nextLevel = 10;
            else if (brightnessRoot.currentLevel === 10) nextLevel = 100;

            setBrightnessCmd.command = ["brightnessctl", "set", nextLevel + "%"];
            setBrightnessCmd.running = true;

            brightnessRoot.currentLevel = nextLevel;
        }
    }

    Process {
        id: fetchBrightnessCmd
        command: [Quickshell.shellPath("scripts/brightness-get.sh")]
        stdout: SplitParser {
            onRead: (line) => {
                let level = parseInt(line.trim());
                if (!isNaN(level)) {
                    brightnessRoot.currentLevel = level;
                }
            }
        }
    }
    Process {
        id: setBrightnessCmd
    }

    Timer {
        interval: 5003
        running: true
        repeat: true
        onTriggered: fetchBrightnessCmd.running = true
        Component.onCompleted: fetchBrightnessCmd.running = true
    }
}
