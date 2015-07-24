import QtQuick 2.4
import U1db 1.0 as U1db

Item {

    property alias current: currentBill
    // will replace by a query later on
    property alias bills: db

    Bill {
        id: currentBill

        Component.onCompleted: reset()
    }

    U1db.Database {
        id: db
        path: "bills.u1db"
    }

    function refreshCurrent() {
        // create a new docID if not saved already
        if (!currentBill.billId)
            currentBill.billId = Date.now();
        // TODO: handle error
        var result = db.putDoc(currentBill.tojson(), currentBill.billId);
    }

    function deleteCurrent() {
        if (!currentBill.billId) {
            // TODO: show error in a toast
            console.log("Error, not saved yet");
            return;
        }
        currentBill.delete(currentBill.billID);
    }

    function deleteBill(docId) {
        db.deleteDoc(docId);

        // if current Bill as well, reset it
        if (currentBill.billId === docId)
            currentBill.reset();
    }

}
