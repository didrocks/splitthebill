import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Content 1.1

Item {
    id: root

    property var activeTransfer
    property QtObject billsHandler

    function pick() {
        pageStack.push(picker);
    }

    Connections {
        target: activeTransfer
        onStateChanged: {
            /*
             * We move manually every item of the temp import filename in the permanent content app store to the
             * destination name. We can't save it directly to it aborts the transfer if we already have a file with the
             * same file name (even with different content), and thus, doesn't give a chance for us to even rename it.
             * https://bugs.launchpad.net/ubuntu/+source/content-hub/+bug/1483589
             * TODO: how to clean old files?????
             */
            if (activeTransfer.state === ContentTransfer.Charged) {
                var uri = "%1/attachments/%2".arg(appStore.uri.toString().substring(0, appStore.uri.toString().lastIndexOf("/")))
                                             .arg(billsHandler.current.billId);
                var importItems = activeTransfer.items;
                for (var i = 0; i < importItems.length; i++) {
                    /* Have to save the full absolute path for rerence (see last line of description in
                      https://bugs.launchpad.net/ubuntu/+source/content-hub/+bug/1483589 */
                    var ext = importItems[i].url.toString().substr(importItems[i].url.toString().lastIndexOf('.') + 1);
                    var j = 1;
                    var filename = "attach%1.%2".arg(j).arg(ext);
                    while (!importItems[i].move(uri, filename)) {
                        j++;
                        filename = "attach%1.%2".arg(j).arg(ext);
                    }
                    billsHandler.current.attachments.append({"url": importItems[i].url.toString()});
                }
            }
        }
    }

    ContentTransferHint {
        anchors.fill: parent
        activeTransfer: root.activeTransfer
    }

    /* we don't direct request to the permanent app local store directly (see above) */
    ContentStore {
        id: appStore
        scope: ContentScope.App
    }

    Page {
        id: picker
        visible: true
        ContentPeerPicker {
            id: peerPicker
            handler: ContentHandler.Source
            // TO ASK: if we want to import Pictures OR Documents (but in one shot)?
            contentType: ContentType.Pictures
            onPeerSelected: {
                peer.selectionType = ContentTransfer.Multiple;
                activeTransfer = peer.request(appStore);
                pageStack.pop();
            }
        }
    }
}
