import QtQuick 2.0
import Ubuntu.Components 1.2

ListItem {

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

    Label { text: bill.title }

    onClicked: console.log("foo")
    onPressAndHold: billsList.editBill(index);

}
