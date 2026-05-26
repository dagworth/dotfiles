import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: soundButton
    color: active ? mainColor : secondaryColor
    height: 45
    width: 45
    radius: 10

    property int volume: 0
    property bool active: false
    property int startvolume: 0

    Text {
        anchors.centerIn: parent
        color: mainTextColor
        font.pixelSize: 32
        font.family: custom_font.name

        text: {
            if (volume == 0)  return "󰕿"
            else if (volume < 35)  return "󰖀"
            return "󰕾"
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        property real startpos: 0

        onPressed: {
            active = true
            startpos = mouseX
            startvolume = volume
        }

        onPositionChanged: {
            if (pressed) {
                let diff = (mouseX - startpos) * .5
                volume = Math.max(0, Math.min(100, startvolume + diff))
            }
        }

        onReleased: {
            active = false
            Quickshell.execDetached({
                command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (volume/100).toString()]
            })
        }
    }

    Component.onCompleted: {
        init.running = true
    }

    Process {
        id: init
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}'"]
        running: false
        
        stdout: SplitParser {
            onRead: (line) => {
                let val = parseInt(line);
                if (!isNaN(val)) volume = val;
            }
        }
    }

    Process {
        id: monitor
        command: [
            "bash", 
            "-c", 
            "pactl subscribe | grep --line-buffered 'sink' | while read -r _; do wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}'; done"
        ]
        running: true

        stdout: SplitParser {
            onRead: (line) => {
                let val = parseInt(line);
                if (!isNaN(val)) volume = val;
            }
        }
    }

    PopupWindow {
        id: popup
        visible: area.pressed
        implicitWidth: 300
        implicitHeight: 30
        color: "transparent"
        
        anchor {
            window: rootBar
            item: soundButton
            rect.y: soundButton.y + soundButton.height + 5
        }

        RowLayout {
            anchors.fill: parent
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 250
                Layout.preferredHeight: 30
                opacity: popup.visible ? 1 : 0
                color: secondaryColor
                radius: 10

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    height: 10
                    width: parent.width - 20
                    color: backgroundColor
                    radius: 5
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    height: 10
                    width: (soundButton.volume / 100) * (parent.width - 20)
                    color: mainColor
                    radius: 5
                }

                Rectangle {
                    height: 14
                    width: 3
                    color: mainTextColor
                    radius: 2
                    
                    anchors.verticalCenter: parent.verticalCenter
                    x: 8.5 + ((startvolume / 100) * (parent.width - 20))
                }
            }

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 30
                color: secondaryColor
                radius: 10

                Text {
                    anchors.fill: parent
                    
                    text: soundButton.volume
                    color: mainTextColor
                    font.pixelSize: 18
                    font.bold: true
                    font.family: custom_font.name
                    
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}