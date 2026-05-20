import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications


PanelWindow {
    id: root
    property color backgroundColor: '#99343434' //99343434

    anchors.top: true
    anchors.left: true
    anchors.right: true
    
    implicitHeight: 80
    color: "transparent"

    NotificationServer {
        id: server
        onNotification: function(n) {
            n.tracked = true;
        }
    }

    FileView {
        id: batteryFile
        path: "/sys/class/power_supply/BAT0/capacity"
    }

    FontLoader {
        id: custom_font
        source: "./iosevka-nerd-font.ttf"
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6

        RowLayout {
            anchors.left: parent.left
            anchors.top: parent.top 
            anchors.bottom: parent.bottom
            spacing: 20

            Workspaces { Layout.leftMargin: 10 }
            SpotifyPlayer {}
        }

        WeatherTime {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 15
        }

        RowLayout {
            anchors.right: parent.right
            anchors.top: parent.top 
            anchors.topMargin: 15

            spacing: 12

            Item { Layout.fillWidth: true }
            ActiveWindow  {Layout.rightMargin: 5}
            PowerProfile {Layout.rightMargin: 5}
            CPUTemp {Layout.rightMargin: 5}
            Battery {Layout.rightMargin: 5}
        }
    }

    NotificationWindow {}
}
