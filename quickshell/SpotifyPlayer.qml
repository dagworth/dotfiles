import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick.Effects

Rectangle {
    id: spotifyBubble
    color: backgroundColor
    radius: 12
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: 60
    Layout.topMargin: 15

    property var spotifyPlayer: {
        if (!Mpris.players || !Mpris.players.values) return null;
        for (const player of Mpris.players.values) {
            if (player && player.identity && player.identity.toLowerCase() === "spotify") {
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

    Layout.preferredWidth: 360

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 15
        spacing: 10

        Item {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: albumArt
                anchors.fill: parent
                source: spotifyPlayer ? spotifyPlayer.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                visible: false
                onStatusChanged: if (status == Image.Error) source = "image://icon/media-playback-start"
            }

            Rectangle {
                id: maskShape
                anchors.fill: parent
                radius: 12
                visible: false
                layer.enabled: true
            }

            MultiEffect {
                anchors.fill: parent
                source: albumArt
                maskSource: maskShape
                maskEnabled: true
            }
        }

        ColumnLayout {
            spacing: 2
            Text {
                text: spotifyPlayer ? (spotifyPlayer.trackTitle + " - " + spotifyPlayer.trackArtist) : "spotify down :("
                color: "#cdd6f4"
                font.family: custom_font.name
                font.pixelSize: 17
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                font.family: custom_font.name
                text: spotifyPlayer ? (spotifyBubble.formatTime(spotifyPlayer.position) + " / " + spotifyBubble.formatTime(spotifyPlayer.length)) : "??:?? / ??:??"
                color: '#9ca6adc8' 
                font.pixelSize: 14
                font.bold: true
            }
        }

        RowLayout {
            spacing: 15
            Layout.alignment: Qt.AlignVCenter

            //back
            Text {
                text: "󰒮"
                font.pixelSize: 25
                color: "#cdd6f4"
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
                font.pixelSize: 30
                color: "#cdd6f4"
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
                font.pixelSize: 25
                color: "#cdd6f4"
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