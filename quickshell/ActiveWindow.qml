import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick.Effects

Rectangle {
    id: windowTitleBubble
    color: backgroundColor
    radius: 12
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: 60
    width: 400

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15

        Text {
            id: winText
            
            text: (Hyprland.activeToplevel && Hyprland.activeToplevel.title !== "") 
                ? Hyprland.activeToplevel.title 
                : "Desktop"
            
            color: mainColor
            font.family: custom_font.name
            font.pixelSize: 20
            font.bold: true
            
            elide: Text.ElideRight
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}