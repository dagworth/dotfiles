import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Rectangle {
    color: backgroundColor
    radius: bubbleRadius
    Layout.alignment: Qt.AlignTop
    height: bubbleHeight
    Layout.topMargin: bubbleTopMargin
    width: screen.width * .125
    clip: true

    id: root

    property NotificationServer server: NotificationServer {}

    property string notifSender: ""
    property string notifBody: ""
    property string notifChannel: ""
    property string notifTime: ""
    property bool hasNotif: notifSender !== ""

    Connections {
        target: root.server
        function onNotification(notification) {
            if (!notification.appName.toLowerCase().includes("discord")) return

            let summary = notification.summary
            let body    = notification.body

            let chanMatch = summary.match(/^(.+?)\s+\(#(.+?)\)$/)
            if (chanMatch) {
                notifSender  = chanMatch[1]
                notifChannel = "#" + chanMatch[2]
            } else {
                notifSender  = summary
                notifChannel = ""
            }
            notifBody = body
            notifTime = Qt.formatTime(new Date(), "hh:mm")

            clearTimer.restart()
        }
    }

    property real fillOpacity: hasNotif ? 0.18 : 0.0
    Behavior on fillOpacity {
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        radius: bubbleRadius
        color: "#5865F2"
        opacity: parent.fillOpacity
    }

    Timer {
        id: clearTimer
        interval: 30000
        onTriggered: {
            notifSender  = ""
            notifBody    = ""
            notifChannel = ""
            notifTime    = ""
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 12
        spacing: 8

        ColumnLayout {
            spacing: 1
            Layout.fillWidth: true

            Text {
                text: hasNotif
                    ? (notifSender + (notifChannel !== "" ? " - " + notifChannel : ""))
                    : "discord"
                color: hasNotif ? mainTextColor : fadedTextColor
                font.family: custom_font.name
                font.pixelSize: bubbleHeight * 17/60
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                text: hasNotif ? notifBody : "no notifications"
                color: fadedTextColor
                font.family: custom_font.name
                font.pixelSize: bubbleHeight * 13/60
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: notifTime
                color: fadedTextColor
                font.family: custom_font.name
                font.pixelSize: bubbleHeight * 11/60
                visible: hasNotif
            }

            Text {
                text: "✕"
                color: fadedTextColor
                font.pixelSize: bubbleHeight * 14/60
                visible: hasNotif
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        notifSender  = ""
                        notifBody    = ""
                        notifChannel = ""
                        notifTime    = ""
                    }
                }
            }
        }
    }
}