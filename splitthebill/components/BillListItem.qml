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

    Button { text: bill.title }

    onClicked: {
        billsHandler.current.loadFromJson(bill);
        mainview.editCurrentBill();
    }
}
