import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: weatherTime
    color: backgroundColor
    radius: 12
    Layout.alignment: Qt.AlignTop
    Layout.topMargin: 15
    Layout.preferredHeight: 60
    Layout.preferredWidth: centerRow.implicitWidth + 24

    property bool isDaytime: true
    function getWeatherIcon(condition, isDay) {
        let cond = condition.toLowerCase();
        if (cond.includes("sunny") || cond.includes("clear")) 
            return isDay ? "󰖙" : "󰖔";
        if (cond.includes("partly")) 
            return isDay ? "󰖕" : "󰼱";
        if (cond.includes("cloud") || cond.includes("overcast")) 
            return "󰖐";
        if (cond.includes("rain") || cond.includes("drizzle") || cond.includes("shower")) 
            return "";
        if (cond.includes("thunder") || cond.includes("storm")) 
            return "󰖓";
        if (cond.includes("snow") || cond.includes("ice") || cond.includes("blizzard")) 
            return "󰖘";
        if (cond.includes("fog") || cond.includes("mist")) 
            return "󰖑";
        return isDay ? "󰖙" : "󰖔";
    }

    RowLayout {
        id: centerRow
        anchors.centerIn: parent
        spacing: 30

        ColumnLayout {
            spacing: -2

            //time
            Text {
                id: timeText
                color: mainColor
                font.family: custom_font.name
                font.pixelSize: 27
                font.bold: true
                Layout.alignment: Qt.AlignLeft
            }

            //date
            Text {
                id: dateText
                color: fadedTextColor
                font.family: custom_font.name
                font.pixelSize: 17
                Layout.alignment: Qt.AlignLeft
            }
        }

        //weather
        RowLayout {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: weatherTime.getWeatherIcon(weatherFetcher.condition, weatherTime.isDaytime)
                color: mainColor
                font.pixelSize: 30
            }

            Text {
                text: weatherFetcher.temp
                color: mainTextColor
                font.family: custom_font.name
                font.pixelSize: 25
                font.bold: true
            }
        }
    }

    //clock
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            let d = new Date();
            timeText.text = d.toLocaleTimeString(Qt.locale(), "h:mm:ss AP"); 
            dateText.text = d.toLocaleDateString(Qt.locale(), "dddd, MMMM d");

            let currentHour = d.getHours();
            weatherTime.isDaytime = (currentHour >= 6 && currentHour < 22);
        }
        Component.onCompleted: triggered()
    }

    Process {
        id: weatherFetcher
        property string temp: "........."
        property string condition: "unknown"
        
        running: true 

        command: [
            "sh", "-c", 
            "while true; do curl -s 'wttr.in/?format=%C|%t' | tr -d '+'; echo; sleep 300; done"
        ]
        
        stdout: SplitParser {
            onRead: (line) => {
                let cleanLine = line.trim();
                if (cleanLine !== "" && !cleanLine.includes("Unknown")) {
                    let parts = cleanLine.split("|");
                    if (parts.length === 2) {
                        weatherFetcher.condition = parts[0].trim();
                        weatherFetcher.temp = parts[1].trim();
                    }
                }
            }
        }
    }
}