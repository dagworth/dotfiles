import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root
    property color backgroundColor: '#81343434' //d21e141e

    anchors.top: true
    anchors.left: true
    anchors.right: true
    
    implicitHeight: 40
    color: "transparent"

    FileView {
        id: batteryFile
        path: "/sys/class/power_supply/BAT0/capacity"
    }

    FontLoader {
        id: custom_font
        source: "./iosevka-nerd-font.ttf"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: 10

        Workspaces {}
        SpotifyPlayer {}
        Item { Layout.fillWidth: true }

        WeatherTime {}

        // Bluetooth {}
        Battery {}
    }
}