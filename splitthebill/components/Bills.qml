import QtQuick 2.4
import U1db 1.0 as U1db

Item {

    property alias current: current
    property alias all: all

    Bill {
        id: current

        Component.onCompleted: reset()
    }

    U1db.Database {
        id: db
        path: "bills.u1db"
    }

    U1db.Index
    {
        database: db
        id: dateIndex
        expression: ["date"]
    }

    U1db.Query
    {
        id: all
        index: dateIndex
    }

    function refreshCurrent() {
        // create a new docID if not saved already
        if (!current.billId)
            current.billId = Date.now();
        // TODO: handle error
        var result = db.putDoc(current.tojson(), current.billId);
    }

    function deleteCurrent() {
        if (!current.billId) {
            // TODO: show error in a toast
            console.log("Error, not saved yet");
            return;
        }
        current.delete(current.billID);
    }

    function deleteBill(docId) {
        db.deleteDoc(docId);

        // if current Bill as well, reset it
        if (current.billId === docId)
            current.reset();
    }

}
