import QtQuick 2.0
import Ubuntu.Components 1.2

ListItem {
    id: root

    property bool _expand: false
    height: _expand ? content.implicitHeight + units.gu(1) : implicitHeight
    Behavior on height {
        SmoothedAnimation {
            duration: UbuntuAnimation.FastDuration
            easing.type: Easing.OutBounce
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
                text: bill.shareBill
                fontSize: "small"
                color: UbuntuColors.lightAubergine
            }
            Label {
                text: "$"
                fontSize: "small"
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
            text: "You paid for %1 out of %2 persons.".arg(bill.numSharePeople).arg(bill.numTotalPeople)
            wrapMode: Text.WordWrap
        }
        Label {
            anchors { left: parent.left; right: parent.right }
            text: "Total price was: %1 $, with %2% tip.".arg(bill.totalBill).arg(bill.tipShare)
            wrapMode: Text.WordWrap
        }
    }

    onFocusChanged: { if (!focus) _expand = false }
    onClicked: { _expand ? _expand = false : _expand = true }

    onPressAndHold: billsListPage.editBill(index);
}
