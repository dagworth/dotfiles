import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    color: backgroundColor
    radius: 5
    Layout.preferredHeight: 20
    Layout.alignment: Qt.AlignTop
    Layout.topMargin: 6

    width: 35

    Text {
        anchors.centerIn: parent
        text: batteryFile.text() !== "" 
            ? "󰂂 " + batteryFile.text().trim()
            : "󰂂 ??"
        color: "lightgreen"
        font.pixelSize: 11
        font.bold: true
    }
}