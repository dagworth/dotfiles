import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ColumnLayout {
    id: battery

    Layout.preferredHeight: 50
    Layout.preferredWidth: 40

    Layout.alignment: Qt.AlignTop
    Layout.topMargin: -3

    spacing: -31

    property string currentBat: "100"

    FileView {
        id: batteryFile
        path: "/sys/class/power_supply/BAT0/capacity"
    }

    Text {
        text: "󰂀"
        color: {
            if(battery.currentBat >= 20) {
                return mainColor
            } else {
                return "red"
            }
        }
        font.family: custom_font.name
        font.pixelSize: 50
    }

    Text {
        Layout.leftMargin: 2.5
        text: {
            if(battery.currentBat == 100) {
                return ":)"
            } else {
                return battery.currentBat
            }
        }
        color: darkColor
        font.family: custom_font.name
        font.pixelSize: 16
        font.bold: true
    }

    Process {
        id: batFetcher
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() !== "") {
                    battery.currentBat = line.trim();
                }
            }
        }
    }

    Timer {
        interval: 15002
        running: true
        repeat: true
        onTriggered: batFetcher.running = true
        Component.onCompleted: batFetcher.running = true
    }
}