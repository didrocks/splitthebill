import QtQuick 2.4
import U1db 1.0 as U1db
import Ubuntu.Components 1.2

Item {
    property alias current: current
    property alias all: all

    Bill {
        id: current
        StateSaver.properties: "billId date"

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
        id: allIndex
        /* You have to specify in the index all fields you want to retrieve
           The query should return the whole document, not just indexed fields
           https://bugs.launchpad.net/u1db-qt/+bug/1271973 */
        expression: ["title", "date", "rawBill", "tipShare", "numTotalPeople", "numSharePeople"]
    }

    /*
     * Use a query instead of getDocs() or directly use the db of model as deleted docs would still be listed otherwise.
     * See bug https://bugs.launchpad.net/u1db-qt/+bug/1219862
     */
    U1db.Query
    {
        id: all
        index: allIndex
    }

    function saveCurrent() {
        // create a new docID if not saved already
        if (!current.billId)
            current.billId = Date.now();
        // TODO: show error in toast
        var result = db.putDoc(current.toJson(), current.billId);
    }

    function deleteBill(docId) {
        db.deleteDoc(docId);

        // if current Bill as well, reset it
        if (current.billId === docId)
            current.reset();
    }
}
