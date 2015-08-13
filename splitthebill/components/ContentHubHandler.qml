import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Content 1.1

Item {
    id: root

    property QtObject billsHandler

    property alias _url: picker.url
    property alias _to: picker.to
    property alias _contentStore: picker.contentStore

    property var _activeTransfer: null

    function open(url, contentType) {
        // TODO: open in default application
        pageStack.push(picker, {"url": url, "to": ContentHandler.Destination, "contentType": contentType,
                                "selectionType": ContentTransfer.Single, "contentStore": null});
    }

    function importFrom(contentType) {
        pageStack.push(picker, {"to": ContentHandler.Source, "contentType":  contentType,
                                "selectionType": ContentTransfer.Multiple, "contentStore": appContentStore});
    }

    Page {
        id: picker
        visible: false

        property var url
        property var to
        property var contentType
        property var selectionType
        property var contentStore

        ContentPeerPicker {
            id: peerPicker
            handler: picker.to
            contentType: picker.contentType
            onPeerSelected: {
                peer.selectionType = picker.selectionType;
                root._activeTransfer = peer.request(root._contentStore);
                pageStack.pop();
            }
        }
    }

    ContentTransferHint {
        anchors.fill: parent
        activeTransfer: root._activeTransfer
    }

    /* we don't direct import request to the permanent app local store directly (see comments in state changed) */
    ContentStore {
        id: appContentStore
        scope: ContentScope.App
    }

    Component {
        id: resultComponent
        ContentItem {}
    }

    Connections {
        target: _activeTransfer
        onStateChanged: {
            if (root._to === ContentHandler.Source) {
                /*
                 * We move manually every item of the temp import filename in the permanent content app store to the
                 * destination name. We can't save it directly to it aborts the transfer if we already have a file with the
                 * same file name (even with different content), and thus, doesn't give a chance for us to even rename it.
                 * https://bugs.launchpad.net/ubuntu/+source/content-hub/+bug/1483589
                 * TODO: how to clean old files?????
                 */
                if (_activeTransfer.state === ContentTransfer.Charged) {
                    var uri = "%1/attachments/%2".arg(_contentStore.uri.toString().substring(0, _contentStore.uri.toString().lastIndexOf("/")))
                                                 .arg(billsHandler.current.billId);
                    var importItems = _activeTransfer.items;
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
            } else if (_to === ContentHandler.Destination) {
                if (_activeTransfer.state === ContentTransfer.InProgress) {
                    root._activeTransfer.items = [resultComponent.createObject(root, {"url": _url})];
                    root._activeTransfer.state = ContentTransfer.Charged;
                }
            }

            // TODO: error handling (Aborted). Also remove all Pictures/* (if import failed)
        }
    }
}
