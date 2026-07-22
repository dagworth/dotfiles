import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications


PanelWindow {
    id: rootBar
    property color backgroundColor: "#99343434" //99343434
    property color mainTextColor: "#cdd6f4" //cdd6f4
    property color fadedTextColor: "#9ca6adc8" //9ca6adc8

    property color mainColor: "#5daca2" //5daca2
    property color secondaryColor: "#2f5550" //45475a

    property color darkColor: '#0c2930' //1e141e1

    property int bubbleHeight: screen.height * .04
    property int bubbleTopMargin: screen.height * .00975
    property int bubbleRadius: bubbleHeight/5

    property int buttonHeight: bubbleHeight*3/4
    property int buttonRadius: buttonHeight*10/45
    property int buttonTopMargin: buttonHeight*8/45

    anchors.top: true
    anchors.left: true
    anchors.right: true
    
    implicitHeight: screen.height * .05
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

        RowLayout {
            anchors.left: parent.left
            anchors.top: parent.top 
            anchors.bottom: parent.bottom
            spacing: bubbleHeight*.33

            Workspaces { Layout.leftMargin: bubbleTopMargin }
            SpotifyPlayer {}
        }

        WeatherTime {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: bubbleTopMargin
        }

        // ActiveWindow {
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.left: parent.left
        //     anchors.leftMargin: 1500
        // }

        RowLayout {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: bubbleHeight*.55

            DiscordNotif {}

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: bubbleTopMargin
                anchors.rightMargin: bubbleTopMargin
                color: backgroundColor
                radius: bubbleRadius

                height: bubbleHeight
                width: row.implicitWidth
                
                RowLayout {
                    id: row
                    anchors.fill: parent
                    spacing: bubbleHeight/4.5
                    //CPUTemp {}
                    Item { Layout.fillWidth: true }
                    Sound {}
                    PowerProfile {}
                    Bluetooth {}
                    Battery {}
                }
            }
        }
    }

    // NotificationWindow {}
}
