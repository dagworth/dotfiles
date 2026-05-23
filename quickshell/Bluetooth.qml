import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

Rectangle {
    id: bluetoothWindow
    width: 320
    height: 400
    color: "transparent"

    property bool bluetoothOn: false
    property string deviceListRaw: ""
    property bool showDiscoveryView: false

    // Theme references 
    property color accentColor: "#E2583E" 
    property color surfaceColor: "#2a1e1b"
    property color textMuted: "#888888"


    // 1. Monitor Power State
    Process {
        id: checkPower
        command: ["bluetoothctl", "show"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                if (data.includes("Powered:")) {
                    bluetoothOn = data.includes("yes");
                }
            }
        }
    }

    // 2. Fetch Paired Devices
    Process {
        id: fetchPairedDevices
        command: ["bluetoothctl", "devices"]
        running: bluetoothOn && !showDiscoveryView
        stdout: SplitParser {
            onRead: (data) => { deviceListRaw += data + "\n"; }
        }
        onExited: (code) => parseDevicesToModel(false)
    }

    // 3. Scan & Fetch Unpaired Devices
    Process {
        id: runScanner
        command: ["bluetoothctl", "scan", "on"]
        running: bluetoothOn && showDiscoveryView
        stdout: SplitParser {
            onRead: (data) => {
                // Captures discovery lines like "[NEW] Device AA:BB:CC... Name"
                if (data.includes("Device ")) {
                    deviceListRaw += data + "\n";
                    parseDevicesToModel(true);
                }
            }
        }
    }

    // 4. Action Command: Toggle Power
    Process {
        id: togglePower
        command: ["bluetoothctl", "power", bluetoothOn ? "off" : "on"]
        onExited: (code) => refreshBackend()
    }

    // 5. Action Command: Connect / Disconnect Paired Device
    Process {
        id: toggleDeviceConnection
        property string targetMac: ""
        property bool currentlyConnected: false
        command: ["bluetoothctl", currentlyConnected ? "disconnect" : "connect", targetMac]
        onExited: (code) => refreshBackend()
    }

    // 6. Action Command: Pair Unpaired Device (Trust -> Pair -> Connect)
    Process {
        id: pairNewDevice
        property string targetMac: ""
        // Runs a multi-command chain natively via bash sequence to bind securely
        command: ["bash", "-c", "bluetoothctl trust " + targetMac + " && bluetoothctl pair " + targetMac + " && bluetoothctl connect " + targetMac]
        onExited: (code) => {
            showDiscoveryView = false; // Flip back to paired view once done
            refreshBackend();
        }
    }

    // Polling Backend Sync
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: refreshBackend()
    }

    function refreshBackend() {
        checkPower.start();
        if (bluetoothOn) {
            deviceListRaw = "";
            // If viewing paired, clear and rebuild list. (Discovery accumulates live updates)
            if (!showDiscoveryView) {
                deviceModel.clear();
                fetchPairedDevices.start();
            }
        } else {
            deviceModel.clear();
        }
    }

    function parseDevicesToModel(isDiscoveryStream) {
        let lines = deviceListRaw.split("\n");
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].trim();
            
            // Clean up discovery prefixes if present
            if (line.includes("Device ")) {
                let cleanLine = line.substring(line.indexOf("Device "));
                let parts = cleanLine.split(" ");
                if (parts.length >= 3) {
                    let mac = parts[1];
                    let name = parts.slice(2).join(" ");
                    
                    // Prevent duplicate list additions
                    let exists = false;
                    for (let j = 0; j < deviceModel.count; j++) {
                        if (deviceModel.get(j).mac === mac) {
                            exists = true;
                            break;
                        }
                    }
                    
                    if (!exists) {
                        deviceModel.append({
                            "mac": mac,
                            "name": name,
                            "connected": false,
                            "isUnpaired": isDiscoveryStream
                        });
                    }
                }
            }
        }
    }

    ListModel {
        id: deviceModel
    }

    // ─── VISUAL LAYOUT CONTAINER ─────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#1a1210" 
        radius: 16
        border.color: "#2a1e1b"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // ─── HEADER ROW (TITLE + MASTER TOGGLE) ──────────────────
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "Bluetooth"
                    color: "#ffffff"
                    font.family: custom_font.name
                    font.pixelSize: 16
                    font.bold: true
                    Layout.fillWidth: true
                }

                // Master Power Switch
                Rectangle {
                    id: masterToggle
                    width: 44
                    height: 24
                    radius: 12
                    color: bluetoothOn ? accentColor : surfaceColor
                    border.color: bluetoothOn ? "transparent" : "#44322e"
                    border.width: 1

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: "#ffffff"
                        y: 4
                        x: bluetoothOn ? parent.width - width - 4 : 4
                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: togglePower.start()
                    }
                }
            }

            // ─── VIEW SWITCH PILL (PAIRED VS DISCOVER) ─────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 32
                color: surfaceColor
                radius: 8
                visible: bluetoothOn

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Left Tab: Paired
                    Rectangle {
                        id: tabPaired
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: !showDiscoveryView ? "#3a2b27" : "transparent"
                        radius: 6
                        Layout.margins: 3

                        Text {
                            anchors.centerIn: parent
                            text: "Paired"
                            color: !showDiscoveryView ? "#ffffff" : textMuted
                            font.family: custom_font.name
                            font.pixelSize: 12
                            font.bold: !showDiscoveryView
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                showDiscoveryView = false;
                                refreshBackend();
                            }
                        }
                    }

                    // Right Tab: Discover
                    Rectangle {
                        id: tabDiscover
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: showDiscoveryView ? accentColor : "transparent"
                        radius: 6
                        Layout.margins: 3

                        Text {
                            anchors.centerIn: parent
                            text: "Discover"
                            color: showDiscoveryView ? "#ffffff" : textMuted
                            font.family: custom_font.name
                            font.pixelSize: 12
                            font.bold: showDiscoveryView
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                deviceModel.clear();
                                deviceListRaw = "";
                                showDiscoveryView = true;
                                runScanner.start();
                            }
                        }
                    }
                }
            }

            // Horizontal separator line
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2d201c"
            }

            // ─── DEVICE SCROLL LIST ──────────────────────────────────
            ListView {
                id: deviceListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6

                model: deviceModel

                Text {
                    anchors.centerIn: parent
                    text: !bluetoothOn ? "Bluetooth is turned off" : (showDiscoveryView ? "Scanning for devices..." : "No paired devices found")
                    color: textMuted
                    font.family: custom_font.name
                    font.pixelSize: 13
                    visible: deviceListView.count === 0
                }

                delegate: Rectangle {
                    id: deviceRow
                    width: deviceListView.width
                    height: 50
                    radius: 10
                    color: model.connected ? "#251a17" : "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onEntered: if (!model.connected) deviceRow.color = "#201614"
                        onExited: if (!model.connected) deviceRow.color = "transparent"
                        
                        onClicked: {
                            if (model.isUnpaired) {
                                pairNewDevice.targetMac = model.mac;
                                pairNewDevice.start();
                            } else {
                                toggleDeviceConnection.targetMac = model.mac;
                                toggleDeviceConnection.currentlyConnected = model.connected;
                                toggleDeviceConnection.start();
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        // Icon handling (shows a radar scan icon for discovery items)
                        Text {
                            text: model.isUnpaired ? "󰭔" : (model.connected ? "" : "")
                            font.family: custom_font.name
                            font.pixelSize: 18
                            color: model.connected || model.isUnpaired ? accentColor : textMuted
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: model.name !== "" ? model.name : model.mac
                                color: "#ffffff"
                                font.family: custom_font.name
                                font.pixelSize: 13
                                font.bold: model.connected
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.isUnpaired ? "Click to Pair" : (model.connected ? "Connected" : "Paired")
                                color: model.connected ? accentColor : textMuted
                                font.family: custom_font.name
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }
    }
}