// ~/.config/quickshell/my-shell/NotificationManager.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: managerRoot
    anchors.fill: parent

    property var rawNotifs: ({})
    property int counter: 0
    
    // 🧱 THE QUEUE: Holds spammy notifications safely in memory
    property var pendingQueue: []
    
    ListModel {
        id: notifModel
    }

    // ⏱️ THE PACEMAKER: Guarantees 350ms of peace between UI updates
    Timer {
        id: queueTimer
        interval: 350 
        onTriggered: managerRoot.processNext()
    }

    // ⚙️ THE ENGINE: Safely takes 1 item from the queue and updates the UI
    function processNext() {
        if (pendingQueue.length === 0) return;
        
        var n = pendingQueue.shift(); // Grab the first item in line
        
        var currentId = managerRoot.counter++;
        var tempDict = managerRoot.rawNotifs;
        tempDict[currentId] = n;
        managerRoot.rawNotifs = tempDict;

        var iconPath = "";
        if (n.image && n.image !== "") {
            iconPath = n.image;
        } else if (n.appIcon && n.appIcon !== "") {
            if (n.appIcon.startsWith("/")) iconPath = "file://" + n.appIcon;
            else iconPath = "image://icon/" + n.appIcon;
        }

        notifModel.append({
            "notifId": currentId,
            "summaryText": n.summary || "",
            "bodyText": n.body || "",
            "iconPath": iconPath
        });

        // Enforce the 4-item limit
        if (notifModel.count > 4) {
            var oldestId = notifModel.get(0).notifId;
            var oldestRaw = managerRoot.rawNotifs[oldestId];
            if (oldestRaw) {
                oldestRaw.tracked = false;
                var dict2 = managerRoot.rawNotifs;
                delete dict2[oldestId];
                managerRoot.rawNotifs = dict2;
            }
            notifModel.remove(0);
        }
        
        // If there are more items waiting, start the timer to process the next one
        if (pendingQueue.length > 0) {
            queueTimer.restart();
        }
    }

    NotificationServer {
        id: server
        onNotification: function(n) {
            n.tracked = true; 
            
            // Push to the safe queue instead of the UI directly
            managerRoot.pendingQueue.push(n);
            
            // If the UI is currently idle, process immediately
            if (!queueTimer.running) {
                managerRoot.processNext();
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        spacing: 12
        model: notifModel
        clip: true
        layoutDirection: Qt.RightToLeft

        // 🟢 RESTORED: Beautiful 300ms smooth animations!
        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300 }
                NumberAnimation { property: "x"; from: 100; to: 0; duration: 300; easing.type: Easing.OutExpo }
            }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; to: 0; duration: 300 }
                NumberAnimation { property: "scale"; to: 0.8; duration: 300; easing.type: Easing.InQuad }
            }
        }

        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 300; easing.type: Easing.OutQuad }
        }

        delegate: Rectangle {
            width: listView.width
            height: 100 
            color: '#282828'
            radius: 12

            Timer {
                interval: 5000 
                running: true  
                onTriggered: {
                    var idToFind = model.notifId;
                    var rawObj = managerRoot.rawNotifs[idToFind];
                    
                    if (rawObj) {
                        rawObj.tracked = false;
                        var tempDict = managerRoot.rawNotifs;
                        delete tempDict[idToFind];
                        managerRoot.rawNotifs = tempDict;
                    }
                    notifModel.remove(index); 
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 18

                Image {
                    Layout.preferredWidth: 75
                    Layout.preferredHeight: 75
                    Layout.alignment: Qt.AlignVCenter
                    fillMode: Image.PreserveAspectFit
                    source: iconPath 
                    visible: iconPath !== ""
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8
                    
                    Text {
                        text: summaryText
                        color: "white"
                        font.bold: true
                        font.pixelSize: 23
                        Layout.fillWidth: true 
                        elide: Text.ElideRight 
                    }
                    
                    Text {
                        text: bodyText
                        color: "#aaaaaa"
                        font.pixelSize: 20
                        Layout.fillWidth: true 
                        elide: Text.ElideRight
                        visible: text !== "" 
                    }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var idToFind = model.notifId;
                    var rawObj = managerRoot.rawNotifs[idToFind];
                    
                    if (rawObj) {
                        if (rawObj.actions) {
                            for (var i = 0; i < rawObj.actions.length; i++) {
                                if (rawObj.actions[i].identifier === "default") {
                                    rawObj.actions[i].invoke();
                                    break;
                                }
                            }
                        }
                        
                        rawObj.tracked = false;
                        var tempDict = managerRoot.rawNotifs;
                        delete tempDict[idToFind];
                        managerRoot.rawNotifs = tempDict;
                    }
                    notifModel.remove(index); 
                }
            }
        }
    }
}