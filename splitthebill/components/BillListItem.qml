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

    Button {
        text: bill.title
    }

    onClicked: {
        var currentBill = billsHandler.current;
        // disable autosave
        currentBill.billId = "";
        // assign all properties from this element
        currentBill.title = bill.title;
        currentBill.date = bill.date;
        currentBill.rawBill = bill.rawBill;
        currentBill.tipShare = bill.tipShare;
        currentBill.numTotalPeople = bill.numTotalPeople;
        currentBill.numSharePeople = bill.numSharePeople;
        // reenable ready for saving
        currentBill.billId = bill.billId;

        page.toogleDetails();
    }

}
