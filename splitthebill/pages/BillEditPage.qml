import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Themes.Ambiance 1.0
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 1.1

import splitthebill 1.0

import "../components"
import "../tools.js" as Tools

Page {
    id: page
    property QtObject billsHandler

    property bool _isEditMode: billsHandler.current.billId

    ContentHubHandler {
        id: contentHubHandler
    }

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
            onTriggered: { contentHubHandler.share(billsHandler.current) }
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

    AttachmentStore {
        id: attachmentStore
        billId: billsHandler.current.billId ? billsHandler.current.billId: ""
    }

    CurrenciesCenter {
        id: currencyCenter
        bill: billsHandler.current
    }

    CurrencyPicker {
        id: currencySelector
    }


    Component {
        id: deletionConfirmationDialog
        Dialog {
            id: dialogue

            property string attachmentUri

            title: "Remove attachment"
            text: "Do you really want to delete this attachement?"

            Row {
                id: row
                width: parent.width
                spacing: units.gu(1)
                Button {
                    width: parent.width/2
                    text: "Cancel"
                    onClicked: PopupUtils.close(dialogue)
                }
                Button {
                    width: parent.width/2
                    text: "Confirm"
                    color: UbuntuColors.green
                    onClicked: {
                        for (var i = 0; i < billsHandler.current.attachments.count; i++) {
                            var elem = billsHandler.current.attachments.get(i);
                            if (elem.url === attachmentUri) {
                                billsHandler.current.attachments.remove(i);
                                break;
                            }
                        }
                        attachmentStore.remove(attachmentUri);
                        PopupUtils.close(dialogue)
                    }
                }
            }
        }
    }

    // COMMENT: fixed headerbar before non fixed triggers the bug
    flickable: null
    Flickable {
        id: editflickable

        anchors.fill: parent
        // better experience: give additional padding below
        contentHeight: mainColumn.height + units.gu(3)
        clip: true

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

            Label {
                id: dateTime
                text: billsHandler.current.formattedDate
                font.pixelSize: units.gu(1.5)

                // COMMENT: present MouseArea and pressed signal (as well are return accepted, looking at documentation)
                MouseArea {
                    anchors.fill: parent
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
                TextField {
                    // TODO: click should select the whole item
                    id: billPrice
                    width: units.gu(13)
                    placeholderText: Tools.displayNum(0.0)
                    errorHighlight: true
                    validator: DoubleValidator {}
                    maximumLength: 7
                    // Keyboard doesn't respect locale: https://launchpad.net/bugs/1488778
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
                Button {
                    id: selectorFrom
                    property int currencyIndex: 0
                    text: billsHandler.current.billCurrencyName
                    onClicked: PopupUtils.open(currencySelector, selectorFrom, {"bill": billsHandler.current})
                    Binding on currencyIndex { value: billsHandler.current.billCurrencyIndex }
                    Binding {
                        target: billsHandler.current
                        property: "billCurrencyIndex"
                        value: selectorFrom.currencyIndex
                    }
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
                currencyName: billsHandler.current.billCurrencyName
                mainValuePrefCurrency: billsHandler.current.totalBillInPrefCurrency
                prefCurrencyName: billsHandler.current.inForeignCurrency ? billsHandler.current.prefCurrencyName: ""
                tipValue: billsHandler.current.totalTip
            }

            Total {
                anchors { left: parent.left; right: parent.right }
                hilight: true
                label: i18n.tr("You pay:")
                mainValue: billsHandler.current.shareBill
                currencyName: billsHandler.current.billCurrencyName
                mainValuePrefCurrency: billsHandler.current.shareBillInPrefCurrency
                prefCurrencyName: billsHandler.current.inForeignCurrency ? billsHandler.current.prefCurrencyName: ""
                tipValue: billsHandler.current.shareTip
            }

            ThinDivider {}

            // COMMENT: explain grid vs Flow
            Flow {
                anchors { left: parent.left; right: parent.right }
                spacing: units.gu(1)

                add: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        easing: UbuntuAnimation.StandardEasing
                        duration: UbuntuAnimation.SlowDuration
                    }
                }
                move: add

                Repeater {
                    model: billsHandler.current.attachments

                    UbuntuShape {
                        id: resImage
                        width: source.width > parent.width ? parent.width : source.width
                        height: units.gu(14)
                        sourceFillMode: UbuntuShape.PreserveAspectCrop
                        source: Image {
                            source: url
                            sourceSize.height: parent.height
                            smooth: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: contentHubHandler.open(url, ContentType.Pictures)
                            onPressed: resImage.state = "PRESSED"
                            onPressAndHold: PopupUtils.open(deletionConfirmationDialog, parent, {"attachmentUri": url})
                            onReleased: resImage.state = "RELEASED"
                            /* COMMENT: first, without this, show that clicking + dragging out doesn't give the
                              onReleased signal. Use then onExited with hoverEnabled: true */
                            hoverEnabled: true
                            onExited: resImage.state = "RELEASED"
                        }

                        /* COMMENT: Behavior on is presented in the UbuntuListView, simple for one element
                         * Then, we can try the onPressed setting values and on presshold, but what happen
                         * on onClicked (if you released quick enough). Better to use States then.
                         */
                        states: [
                            State {
                                name: "PRESSED"
                                PropertyChanges {
                                    target: resImage
                                    sourceOpacity: 0.1
                                    scale: 0.7;
                                }
                            },
                            State {
                                name: "RELEASED"
                                PropertyChanges {
                                    target: resImage
                                    sourceOpacity: 1.0
                                    scale: 1;
                                }
                            }
                        ]
                        // COMMENT: behavior will be easier here, but we want to show how to do more complex animation
                        // Show different in/out animations, Sequential and parallel
                        transitions: Transition {
                            to: "*" // we can have transition from: to:
                            /* Simple case:
                            SequentialAnimation {
                                NumberAnimation { target: resImage; properties: "sourceOpacity"; duration: 1000}
                                NumberAnimation { target: resImage; properties: "scale"; duration: 2000}
                            }*/
                            NumberAnimation {
                                target: resImage;
                                properties: "sourceOpacity, scale";
                                easing: UbuntuAnimation.StandardEasing
                                duration: UbuntuAnimation.SlowDuration
                            }
                        }
                    }
                }
            }

            Button {
                anchors { left: parent.left }
                text: i18n.tr("Add attachments")
                // we don't let people add any attachments before getting a valid directory (billId)
                visible: billsHandler.current.billId
                onClicked: { contentHubHandler.importFrom(billsHandler.current, ContentType.Pictures) }
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
}
