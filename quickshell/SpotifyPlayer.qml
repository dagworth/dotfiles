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
    radius: 5
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: 30
    Layout.topMargin: 6

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

    Layout.preferredWidth: 180

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 3
        anchors.rightMargin: 10
        spacing: 4

        Item {
            Layout.preferredWidth: 25
            Layout.preferredHeight: 25
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
                radius: 4
                visible: false
            }

            MultiEffect {
                anchors.fill: parent
                source: albumArt
                maskSource: maskShape
            }
        }

        ColumnLayout {
            spacing: 0
            Text {
                text: spotifyPlayer ? (spotifyPlayer.trackArtist + " - " + spotifyPlayer.trackTitle) : "spotify down :("
                color: "#cdd6f4"
                font.family: custom_font.name
                font.pixelSize: 9
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                font.family: custom_font.name
                text: spotifyPlayer ? (spotifyBubble.formatTime(spotifyPlayer.position) + " / " + spotifyBubble.formatTime(spotifyPlayer.length)) : "??:?? / ??:??"
                color: '#9ca6adc8' 
                font.pixelSize: 8
                font.bold: true
            }
        }

        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignVCenter

            //back
            Text {
                text: "󰒮"
                font.pixelSize: 11
                color: "#cdd6f4"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.spotifyPlayer && root.spotifyPlayer.canGoPrevious) root.spotifyPlayer.previous()
                }
            }

            //pause
            Text {
                property bool isPlaying: root.spotifyPlayer && root.spotifyPlayer.playbackState === MprisPlaybackState.Playing
                text: isPlaying ? "󰏤" : "󰐊"
                font.pixelSize: 13
                color: "#cdd6f4"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (root.spotifyPlayer) {
                            if (parent.isPlaying) {
                                root.spotifyPlayer.playbackState = MprisPlaybackState.Paused;
                            } else {
                                root.spotifyPlayer.playbackState = MprisPlaybackState.Playing;
                            }
                        }
                    }
                }
            }
            
            //next
            Text {
                text: "󰒭"
                font.pixelSize: 11
                color: "#cdd6f4"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.spotifyPlayer && root.spotifyPlayer.canGoNext) root.spotifyPlayer.next()
                }
            }
        }
    }
}