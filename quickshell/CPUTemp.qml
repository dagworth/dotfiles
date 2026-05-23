import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: tempRoot
    color: "transparent"
    Layout.preferredHeight: 50
    Layout.alignment: Qt.AlignTop
    Layout.topMargin: 5

    width: 60

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -2
        spacing: -32

        Text {
            text: ""
            color: mainColor
            font.family: custom_font.name
            font.pixelSize: 40
            font.bold: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: tempRoot.currentTemp
            color: darkColor
            font.family: custom_font.name
            font.pixelSize: 16
            font.bold: true
        }
    }

    property string currentTemp: ""

    Process {
        id: cpuTempFetcher
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp | awk '{print int($1/1000)}'"]
        
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() !== "") {
                    tempRoot.currentTemp = line.trim();
                }
            }
        }
    }

    Timer {
        interval: 5002
        running: true
        repeat: true
        onTriggered: cpuTempFetcher.running = true
        Component.onCompleted: cpuTempFetcher.running = true
    }
}