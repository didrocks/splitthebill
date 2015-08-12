import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Content 1.1

Item {
    id: root

    property alias _url: picker.url
    property alias _direction: picker.direction

    property var _activeTransfer: null

    function open(url, contentType) {
        pageStack.push(picker, {"url": url, "direction": ContentHandler.Destination, "contentType":  contentType,
                                "selectionType": ContentTransfer.Single});
    }

    Page {
        id: picker
        visible: false

        property var url
        property var direction
        property var contentType
        property var selectionType

        ContentPeerPicker {
            id: peerPicker
            handler: picker.direction
            contentType: picker.contentType
            onPeerSelected: {
                peer.selectionType = picker.selectionType;
                root._activeTransfer = peer.request(null);
                pageStack.pop();
            }
        }
    }

    Component {
        id: resultComponent
        ContentItem {}
    }

    Connections {
        target: _activeTransfer
        onStateChanged: {
            // TODO: remove after getting final state
            console.log("Transfer state changed to: " + _activeTransfer.state)
            if (_activeTransfer.state === ContentTransfer.InProgress) {
                root._activeTransfer.items = [resultComponent.createObject(root, {"url": _url})];
                root._activeTransfer.state = ContentTransfer.Charged;
            }
            // TODO: error handling (Aborted)
        }
    }
}
