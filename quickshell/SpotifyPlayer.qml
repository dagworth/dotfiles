import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick.Effects

Rectangle {
    color: backgroundColor
    radius: bubbleRadius
    Layout.alignment: Qt.AlignTop
    height: bubbleHeight
    Layout.topMargin: bubbleTopMargin
    width: screen.width*.15
    clip: true

    property var spotifyPlayer: {
        if (!Mpris.players || !Mpris.players.values) return null;
        for (const player of Mpris.players.values) {
            if (player && player.identity && player.identity == "Spotify") {
                return player;
            }
        }
        return null;
    }
    
    function formatTime(seconds) {
        if (seconds <= 0 || isNaN(seconds)) return "00:00";
        let mins = Math.floor(seconds / 60);
        let secs = Math.floor(seconds % 60);
        return (mins < 10 ? "0" + mins : mins) + ":" + (secs < 10 ? "0" + secs : secs);
    }

    Rectangle {
        width: {
            if(spotifyPlayer === null) { return 0 }
            (spotifyPlayer.position/spotifyPlayer.length)*screen.width*.15
        }

        height: bubbleHeight
        radius: bubbleRadius
        color: secondaryColor
        visible: spotifyPlayer

        Behavior on width {
            NumberAnimation {
                duration: 2500
                easing.type: Easing.OutCubic
            }
        }
    }

    RowLayout {
        id: bubble
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 15
        spacing: 10

        Item {
            Layout.preferredWidth: bubbleHeight*.833
            Layout.preferredHeight: bubbleHeight*.833
            Layout.alignment: Qt.AlignVCenter
            
            Image {
                id: album
                anchors.fill: parent
                source: spotifyPlayer ? spotifyPlayer.trackArtUrl : ""
                visible: false
            }

            //shape
            Rectangle {
                id: shape
                anchors.fill: parent
                radius: bubbleRadius
                visible: false
                layer.enabled: true
            }

            //mask
            MultiEffect {
                anchors.fill: parent
                source: album
                maskSource: shape
                maskEnabled: true
            }
        }

        ColumnLayout {
            spacing: 2
            Text {
                text: spotifyPlayer ? (spotifyPlayer.trackTitle + " - " + spotifyPlayer.trackArtist) : "spotify down :("
                color: mainTextColor
                font.family: custom_font.name
                font.pixelSize: bubbleHeight*17/60
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                font.family: custom_font.name
                text: spotifyPlayer ? (formatTime(spotifyPlayer.position) + " / " + formatTime(spotifyPlayer.length)) : "??:?? / ??:??"
                color: fadedTextColor
                font.pixelSize: bubbleHeight*14/60
                font.bold: true
            }
        }

        RowLayout {
            spacing: 15
            Layout.alignment: Qt.AlignVCenter

            //back
            Text {
                text: "󰒮"
                font.pixelSize: bubbleHeight*25/60
                color: mainTextColor
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (spotifyPlayer && spotifyPlayer.canGoPrevious) spotifyPlayer.previous()
                }
            }

            //pause
            Text {
                property bool isPlaying: spotifyPlayer && spotifyPlayer.playbackState === MprisPlaybackState.Playing
                text: isPlaying ? "󰏤" : "󰐊"
                font.pixelSize: bubbleHeight*.5
                color: mainTextColor
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (spotifyPlayer) {
                            if (parent.isPlaying) {
                                spotifyPlayer.playbackState = MprisPlaybackState.Paused;
                            } else {
                                spotifyPlayer.playbackState = MprisPlaybackState.Playing;
                            }
                        }
                    }
                }
            }
            
            //next
            Text {
                text: "󰒭"
                font.pixelSize: bubbleHeight*25/60
                color: mainTextColor
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (spotifyPlayer && spotifyPlayer.canGoNext) spotifyPlayer.next()
                }
            }
        }
    }

    Timer {
        running: spotifyPlayer && spotifyPlayer.playbackState === MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: {
            spotifyPlayer.positionChanged()
        }
    }
}