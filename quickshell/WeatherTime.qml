import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: weatherTime
    anchors.centerIn: parent
    color: backgroundColor
    radius: 6
    width: centerRow.implicitWidth + 24
    height: 30

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
            return "󰖎";
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
        spacing: 13

        ColumnLayout {
            spacing: -2

            //time
            Text {
                id: timeText
                color: '#578f59'
                font.family: custom_font.name
                font.pixelSize: 13
                font.bold: true
                Layout.alignment: Qt.AlignLeft
            }

            //date
            Text {
                id: dateText
                color: "#bac2de"
                font.family: custom_font.name
                font.pixelSize: 8
                Layout.alignment: Qt.AlignLeft
            }
        }

        //weather
        RowLayout {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: weatherTime.getWeatherIcon(weatherFetcher.condition, weatherTime.isDaytime)
                color: "#cba6f7"
                font.pixelSize: 14
            }

            Text {
                text: weatherFetcher.temp
                color: "#578f59"
                font.family: custom_font.name
                font.pixelSize: 12
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
            weatherTime.isDaytime = (currentHour >= 6 && currentHour < 18);
        }
        Component.onCompleted: triggered()
    }

    // Grabs the temperature from wttr.in without requiring an API key
    Process {
        id: weatherFetcher
        property string temp: "..."
        property string condition: "Unknown"

        command: ["sh", "-c", "curl -s 'wttr.in/?format=%C|%t' | tr -d '+'"]
        
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

    // Refresh weather every 30 minutes to avoid API rate limits
    Timer {
        interval: 1800000 
        running: true
        repeat: true
        onTriggered: weatherFetcher.running = true
        Component.onCompleted: weatherFetcher.running = true
    }
}