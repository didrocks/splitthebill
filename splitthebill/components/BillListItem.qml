import QtQuick 2.0
import Ubuntu.Components 1.2

ListItem {

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

    Label { text: bill.title }

    onClicked: console.log("foo")
    onPressAndHold: billsListPage.editBill(index);
}
