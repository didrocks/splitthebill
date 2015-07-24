import QtQuick 2.0
import Ubuntu.Components 1.2

ListItem {

    // bound to compute the current values summary
    Bill {
        id: bill
        billId: docId
        title: title
        date: date
        rawBill: rawBill
        tipShare: tipShare
        numTotalPeople: numTotalPeople
        numSharePeople: numSharePeople
    }

    leadingActions: ListItemActions {
        actions: [
            Action {
                iconName: "delete"
            }
        ]
    }
    trailingActions: ListItemActions {
        actions: [
            Action {
                iconName: "share"
            }
        ]
    }

    Button {
        text: "Press me" + bill.billId
    }

    onClicked: console.log("clicked on ListItem with leadingActions set")
}
