import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications


PanelWindow {
    id: root
    property color backgroundColor: "#99343434" //99343434
    property color mainTextColor: "#cdd6f4" //cdd6f4
    property color fadedTextColor: "#9ca6adc8" //9ca6adc8

    property color mainColor: "#5daca2" //5daca2
    property color secondaryColor: "#2f5550" //45475a

    property color darkColor: '#0c2930' //1e141e1

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

    FontLoader {
        id: custom_font
        source: "./Montserrat-Bold.ttf"
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

        // ActiveWindow {
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.left: parent.left
        //     anchors.leftMargin: 1500
        // }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.rightMargin: 10
            color: backgroundColor
            radius: 12

            height: 60
            width: 300

            RowLayout {
                anchors.fill: parent
                spacing: 15
                Item { Layout.fillWidth: true }
                PowerProfile {}
                BluetoothButton {}
                SoundButton {}
                Battery {}
            }
        }
    }

    //NotificationWindow {}
}
