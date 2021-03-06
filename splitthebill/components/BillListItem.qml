import QtQuick 2.0
import Ubuntu.Components 1.2

import "."

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
        currencyFetchDate: model.currencyFetchDate
        // COMMENT: don't databind with default here:
        // Index can be 0 (first item: EUR), so then, index ? is false and it creates a databinding to appsettings
        // default
        billCurrencyIndex: model.billCurrencyIndex
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
                text: bill.inForeignCurrency ?
                          i18n.tr("%1 %2 (%3 %4)").arg(bill.shareBill).arg(bill.billCurrencyName)
                                                  .arg(bill.shareBillInPrefCurrency).arg(bill.prefCurrencyName):
                          i18n.tr("%1 %2").arg(bill.shareBill).arg(bill.billCurrencyName)
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
            // TRANSLATORS: %1 is total price, %2 is currency name, %3 is indication in pref currency, %4 is currency name, %5 is tip %
            text: bill.inForeignCurrency ?
                      i18n.tr("Total price was: %1 %2 (%3 %4), with %5% tip.")
                          .arg(bill.totalBill).arg(bill.billCurrencyName)
                          .arg(bill.totalBillInPrefCurrency).arg(bill.prefCurrencyName)
                          .arg(bill.tipShare) :
                      i18n.tr("Total price was: %1 %2, with %5% tip.")
                          .arg(bill.totalBill).arg(bill.billCurrencyName)
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
