import QtQuick 2.0
import Ubuntu.Components 1.2

import "settings"

ListItem {
    id: root

    property bool _expand: false
    height: _expand ? content.implicitHeight + units.gu(1) : implicitHeight
    Behavior on height {
        SmoothedAnimation {
            duration: UbuntuAnimation.FastDuration
            easing: UbuntuAnimation.StandardEasing
        }
    }

    // bound to compute the current values summary via direct binding
    Bill {
        id: bill
        billId: model.billId
        title: model.title
        date: model.date
        rawBill: model.rawBill
        tipShare: model.tipShare
        numTotalPeople: model.numTotalPeople
        numSharePeople: model.numSharePeople
        // be future-proof when adding new properties
        comments: model.comments ? model.comments: ""
        attachments: model.attachments ? model.attachments : newListModel.createObject(parent)
        currencies: model.currencies ? model.currencies : newCurrenciesModel.createObject(parent)
        currencyFetchDate: model.currencyFetchDate ? model.currencyFetchDate: ''
        billCurrencyIndex: model.billCurrencyIndex ? model.billCurrencyIndex: AppSettings.preferredCurrencyIndex
    }

    NewListModel {
        id: newListModel
    }

    CurrenciesModel {
        id: newCurrenciesModel
    }

    Column {
        id: content
        spacing: units.gu(0.3)
        anchors {
            left: parent.left;
            right: parent.right;
            topMargin: units.gu(0.3);
            bottomMargin: units.gu(0.3) }

        Label {
            id: billTitle
            text: bill.title
            color: UbuntuColors.lightAubergine
        }

        Row {
            spacing: units.gu(0.3)
            Label {
                text: "You payed:"
                fontSize: "small"
            }
            Label {
                text: bill.shareBill.toLocaleCurrencyString(Qt.locale())
                fontSize: "small"
                color: UbuntuColors.lightAubergine
            }
        }

        Label {
            anchors {
                right: parent.right
            }
            // COMMENT: introduce format.arg(parameters) with this
            text: "(%1)".arg(bill.formattedDate)
            fontSize: "small"
        }

        /* here are the details items */
        Item {
            width: parent.width
            height: units.gu(0.5)
        }

        Label {
            // mandatory for wordWrap (setting a width)
            anchors { left: parent.left; right: parent.right }
            text: bill.summary
            wrapMode: Text.WordWrap
        }
        Label {
            anchors { left: parent.left; right: parent.right }
            text: i18n.tr("Total price was: %1, with %2% tip.").arg(bill.totalBill.toLocaleCurrencyString(Qt.locale()))
                                                               .arg(bill.tipShare)
            wrapMode: Text.WordWrap
        }
        Label {
            anchors { left: parent.left; right: parent.right; }
            text: bill.comments
            wrapMode: Text.WordWrap
            fontSize: "small"
        }
    }

    onFocusChanged: { if (!focus) _expand = false }
    onClicked: { _expand ? _expand = false : _expand = true }

    onPressAndHold: billsListPage.editBill(index);
}
