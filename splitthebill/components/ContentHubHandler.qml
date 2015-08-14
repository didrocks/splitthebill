import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Content 1.1
import Ubuntu.Components.Popups 1.0

import splitthebill 1.0

Item {
    id: root

    property alias attachmentStore: attachmentStore.uri

    property alias _url: picker.url
    property alias _to: picker.to
    property alias _contentStore: picker.contentStore
    property alias _currentBill: picker.currentBill

    property var _currentPeer
    property var _activeTransfer: null

    // workaround for transfer not aborted
    property bool _cancelled: false

    function open(url, contentType) {
        pageStack.push(picker, {"url": url, "to": ContentHandler.Destination, "contentType": contentType,
                                "selectionType": ContentTransfer.Single, "contentStore": null});
    }

    function importFrom(currentBill, contentType) {
        pageStack.push(picker, {"currentBill": currentBill, "to": ContentHandler.Source, "contentType":  contentType,
                                "selectionType": ContentTransfer.Multiple, "contentStore": appContentStore});
    }

    function share(currentBill) {
        // TOASK: share an email with an attachement?
        pageStack.push(picker, {"currentBill": currentBill, "to": ContentHandler.Share, "contentType": ContentType.Text,
                                "selectionType": ContentTransfer.Single, "contentStore": null});
    }

    Page {
        id: picker
        visible: false

        property var url
        property var currentBill
        property var to
        property var contentType
        property var selectionType
        property var contentStore

        ContentPeerPicker {
            id: peerPicker
            handler: picker.to
            contentType: picker.contentType
            onPeerSelected: {
                root._currentPeer = peer;
                peer.selectionType = picker.selectionType;
                root._cancelled = false;
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

    AttachmentStore {
        id: attachmentStore
        billId: _currentBill ? _currentBill.billId: ""
        contentStoreInputUri: appContentStore.uri
        onError: {
            PopupUtils.open(errorDisplay, page, {"title": i18n.tr("Transfer issue"), "text": msg});
            // TODO: doesn't abort transfer, open a bug for it, it keeps the transferHint shown
            //_activeTransfer.state = ContentTransfer.Aborted;
            root._cancelled = true; // workaround for cancelling
        }
    }

    ErrorDialog {
        id: errorDisplay
    }

    Component {
        id: resultComponent
        ContentItem {}
    }

    Connections {
        target: _activeTransfer
        onStateChanged: {
            if (root._cancelled) {
                _activeTransfer.state = ContentTransfer.Aborted;
                return;
            }
            if (root._to === ContentHandler.Source) {
                /*
                 * We move manually every item of the temp import filename in the permanent content app store to the
                 * destination name. We can't save it directly to it aborts the transfer if we already have a file with the
                 * same file name (even with different content), and thus, doesn't give a chance for us to even rename it.
                 * https://bugs.launchpad.net/ubuntu/+source/content-hub/+bug/1483589
                 * TODO: how to clean old files?????
                 */
                if (_activeTransfer.state === ContentTransfer.Charged) {
                    var importItems = _activeTransfer.items;
                    for (var i = 0; i < importItems.length; i++) {
                        /* Have to save the full absolute path for reference (see last line of description in
                          https://bugs.launchpad.net/ubuntu/+source/content-hub/+bug/1483589 */
                        var filename = attachmentStore.nextBillAttachRef(importItems[i].url.toString());
                        if (!importItems[i].move(attachmentStore.billUri, filename))
                            _activeTransfer.state = ContentTransfer.Aborted;
                        _currentBill.attachments.append({"url": attachmentStore.billUri + "/" + filename});
                    }
                }
            } else if (_to === ContentHandler.Destination) {
                if (_activeTransfer.state === ContentTransfer.InProgress) {
                    root._activeTransfer.items = [resultComponent.createObject(root, {"url": _url})];
                    root._activeTransfer.state = ContentTransfer.Charged;
                }
            } else if (_to === ContentHandler.Share) {
                if (_activeTransfer.state === ContentTransfer.InProgress) {
                    // we share short message if the destination is twitter or constraint string, larger otherwise
                    var msg = ""
                    if (root._currentPeer.name.indexOf('twitter') !== -1)
                        msg = root._currentBill.shortSummaryShare;
                    else
                        msg = root._currentBill.summaryShare;
                    root._activeTransfer.items = [resultComponent.createObject(root, {"text": msg})];
                    root._activeTransfer.state = ContentTransfer.Charged;
                }
            }
            if (_activeTransfer.state === ContentTransfer.Aborted) {
                PopupUtils.open(errorDisplay, page,
                                {"title": i18n.tr("Transfer issue"),
                                 "text": i18n.tr("Transfer has been aborted. Please retry again later")});
            }
        }
    }
}
