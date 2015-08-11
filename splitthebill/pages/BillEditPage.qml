import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Themes.Ambiance 1.0
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 1.1

import "../components"
import "../tools.js" as Tools

Page {
    id: page
    property QtObject billsHandler

    property var activeTransfer

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
        activeTransfer: page.activeTransfer
    }

    /* we don't direct request to the permanent app local store directly (see above) */
    ContentStore {
        id: appStore
        scope: ContentScope.App
    }

    Page {
        id: picker
        visible: false
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


    property bool _isEditMode: billsHandler.current.billId

    function activate() {
        // focus the name if in edit mode, otherwise, focus the price (not sure someone wants to edit a name)
        if (_isEditMode)
            billName.forceActiveFocus();
        else
            billPrice.forceActiveFocus();
    }

    head.backAction: Action {
        iconName: "close"
        onTriggered: { page.pageStack.pop(); }
    }

    head.actions: [
        // COMMENT: no reset/delete here, (too close from ok -> destructive action)
        Action {
            iconName: "share"
            onTriggered: { /* TODO */ }
        },
        Action {
            iconName: "ok"
            enabled: billsHandler.current.title !== ""
            onTriggered: {
                if (!billsHandler.saveCurrent()) {
                    // TO ASK: why this doesn't work?
                    // file:///usr/lib/x86_64-linux-gnu/qt5/qml/Ubuntu/Components/Popups/popupUtils.js:59: Error: Function.prototype.connect: target is not a function
                    //var errorDisplay = Qt.createComponent("../components/ErrorDialog.qml");
                    //PopupUtils.open(errorDisplay, page, {"title": i18n.tr("Couldn't save bill"),
                    //                "text": i18n.tr("An error happened while trying to save your bill. Please retry saving it.")});
                    PopupUtils.open(errorDisplay, page, {"title": i18n.tr("Couldn't save bill"),
                                    "text": i18n.tr("An error happened while trying to save your bill. Please retry saving it.")});
                }
                else
                    page.pageStack.pop()
            }
        }
    ]

    ErrorDialog {
        id: errorDisplay
    }

    Column {
        id: mainColumn

        spacing: units.gu(1)
        anchors {
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
            // force the column to match page width
            left: parent.left
            right: parent.right
        }

        TextField {
            id: billName
            color: UbuntuColors.lightAubergine
            // use anchors instead of width: parent.width (more performant as don't go to through the binding system)
            anchors { left: parent.left; right: parent.right }
            placeholderText: i18n.tr("New bill split")
            font.pixelSize: units.gu(3)
            // FIXME: use new styling rules (and don't import old)
            style: TextFieldStyle {
                background: Item {}
                color: UbuntuColors.lightAubergine
                frameSpacing: 0
                overlaySpacing: 0
            }
            Binding on text { value: billsHandler.current.title }
            Binding {
                target: billsHandler.current
                property: "title"
                value: billName.text
            }
            StateSaver.properties: "text"
        }

        DateTimeDialog {
            id: dateTimeDialog
        }

        /* TODO: be able to change the date and time. */
        Label {
            id: dateTime
            text: billsHandler.current.formattedDate
            font.pixelSize: units.gu(1.5)

            // COMMENT: present MouseArea and pressed signal (as well are return accepted, looking at documentation)
            MouseArea {
                anchors.fill: parent
                // TODO: to check: click event transposed to a press in touch?
                onClicked: { PopupUtils.open(dateTimeDialog, dateTime) }
                }
        }


        Row {
            id: priceRow

            spacing: units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter

            // COMMENT: RTL isn't respected, this is left as an exercise for the reader :)
            Label {
                text: i18n.tr("Bill:")
                height: parent.height
                verticalAlignment: Text.AlignVCenter
            }
            Label {
                // COMMENT: i18n is not only about translations! It's currency as well.
                text: Qt.locale().currencySymbol()
                height: parent.height
                verticalAlignment: Text.AlignVCenter
            }
            TextField {
                // TODO: click should select the whole item
                id: billPrice
                width: units.gu(13)
                placeholderText: Tools.displayNum(0.0)
                errorHighlight: true
                validator: DoubleValidator {}
                maximumLength: 7
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                // replace after a while with activate() when polishing
                //Component.onCompleted: billPrice.forceActiveFocus()
                // show first the expanded binding syntax, then the reduced one
                Binding on text { value: billsHandler.current.rawBill }
                Binding {
                    target: billsHandler.current
                    property: "rawBill"
                    value: billPrice.text
                    when: billPrice.text !== ""
                }
                StateSaver.properties: "text"
            }
        }

        AddRemoveInt {
            id: numPeople
            anchors { left: parent.left; right: parent.right }
            text: i18n.tr("Number of people:")
            min: 1
            // factorize the databinding inside the factorized object
            modelid: billsHandler.current
            modelPropertyName: "numTotalPeople"
            StateSaver.properties: "currentValue"
        }

        AddRemoveInt {
            id: numPeoplePay
            anchors { left: parent.left; right: parent.right }
            text: i18n.tr("You pay for:")
            min: 1
            max: numPeople.currentValue
            modelid: billsHandler.current
            modelPropertyName: "numSharePeople"
            StateSaver.properties: "currentValue"
        }

        RowLayout {
            id: tipRow
            spacing: units.gu(1)
            anchors { left: parent.left; right: parent.right }
            Label {
                id: labelSlider
                text: i18n.tr("Tip")
                verticalAlignment: Text.AlignVCenter
            }
            Slider {
                id: tipSlider
                minimumValue: 0
                maximumValue: 30
                live: true
                Layout.fillWidth: true
                // for the 2 way databindings episod. Changing the slider breaks the databinding + changing a value
                // through script and see that it breaks with:
                // value: billsHandler.current.tipeShare (this name is direct binding)
                // So, then, use double Binding. Show first the expanded binding notation then the reduced one
                Binding on value { value: billsHandler.current.tipShare }
                Binding {
                    target: billsHandler.current
                    property: "tipShare"
                    value: tipSlider.value
                }
                StateSaver.properties: "value"
            }
            Label {
                id: labelValueSlider
                // TRANSLATORS: tip share in %
                text: i18n.tr("%1%").arg(tipSlider.value.toFixed())
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Light
            }
        }

        ThinDivider {}

        Total {
            anchors { left: parent.left; right: parent.right }
            label: i18n.tr("Total:")
            mainValue: billsHandler.current.totalBill
            tipValue: billsHandler.current.totalTip
        }

        Total {
            anchors { left: parent.left; right: parent.right }
            hilight: true
            label: i18n.tr("You pay:")
            mainValue: billsHandler.current.shareBill
            tipValue: billsHandler.current.shareTip
        }

        ThinDivider {}

        Column {
            anchors { left: parent.left; right: parent.right }
            Repeater {
                model: billsHandler.current.attachments
                Text {
                    width: 50
                    text: url;
                }

                /*UbuntuShape {
                    id: resImage
                    width: image.width
                    height: 100
                    image: Image {
                        source: modelData
                        sourceSize.height: parent.height
                        height: parent.height
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }*/
            }
        }

        Button {
            anchors { left: parent.left }
            text: i18n.tr("Add attachments")
            onClicked: {
                peerPicker.contentType = ContentType.Pictures;
                pageStack.push(picker);
            }
        }

        TextArea {
            id: commentsText
            placeholderText: i18n.tr("Additional notes")
            anchors { left: parent.left; right: parent.right }
            autoSize: true
            maximumLineCount: 4
            Binding on text { value: billsHandler.current.comments }
            Binding {
                target: billsHandler.current
                property: "comments"
                value: commentsText.text
            }
            StateSaver.properties: "comments"
        }

        ThinDivider {}

        Button {
            text: i18n.tr("Reset")
            anchors { left: parent.left; right: parent.right }
            visible: !_isEditMode
            color: UbuntuColors.red
            onClicked: billsHandler.current.reset()
        }

        Button {
            text: i18n.tr("Delete")
            anchors { left: parent.left; right: parent.right }
            visible: _isEditMode
            color: UbuntuColors.red
            onClicked: {
                billsHandler.deleteBill(billsHandler.current.billId);
                page.pageStack.pop();
            }
        }
    }
}
