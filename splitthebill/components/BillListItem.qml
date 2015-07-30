import QtQuick 2.0
import Ubuntu.Components 1.2

ListItem {
    property QtObject billsHandler

    // bound to compute the current values summary via direct binding
    Bill {
        id: bill
        billId: docId
        title: contents.title
        date: contents.date
        rawBill: contents.rawBill
        tipShare: contents.tipShare
        numTotalPeople: contents.numTotalPeople
        numSharePeople: contents.numSharePeople
    }

    // the design constraints are allowing a maximum of 1 action on leading- and a maximum of
    // 3 actions on trailing side of the ListItem.
    leadingActions: ListItemActions {
        actions: [
            Action {
                iconName: "delete"
                onTriggered: billsHandler.deleteBill(bill.billId)
            }
        ]
    }

    trailingActions: ListItemActions {
        actions: [
            Action {
                iconName: "share"
            },
            Action {
                iconName: "edit"
                onTriggered: edit()
            }
        ]
    }

    function edit() {
        billsHandler.current.loadFromJson(bill);
        mainview.editCurrentBill();
    }

    Label { text: bill.title }

    onClicked: console.log("foo")
    onPressAndHold: edit();

}
