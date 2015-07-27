import QtQuick 2.0
import Ubuntu.Components 1.2

ListItem {

    property QtObject billsHandler

    // bound to compute the current values summary via direct binding
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
                onTriggered: billsHandler.deleteBill(bill.billId)
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

    onClicked: {
        console.log("one clicked");
        page.toogleDetails();
    }

}
