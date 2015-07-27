import QtQuick 2.4
import U1db 1.0 as U1db

Item {

    property alias current: current
    property alias all: all

    Bill {
        id: current
        StateSaver.properties: "date"

        // Only reset if not restored (and so, if date isn't attributed)
        Component.onCompleted: {
            if (!date.getDate())
                reset();
        }
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

    /*
     * Use a query instead of getDocs() or directly use the db of model as deleted docs would still be listed otherwise.
     * See bug https://bugs.launchpad.net/u1db-qt/+bug/1219862
     */
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
