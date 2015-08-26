import QtQuick 2.4
import U1db 1.0 as U1db
import Ubuntu.Components 1.2

import splitthebill 1.0

Item {
    id: handler

    property alias current: current
    property alias all: all
    property alias billsResults: billsResults
    readonly property bool isEmpty: (all.results.length === 0)
    readonly property bool noResults: (billsResults.count === 0)
    property string query: ""

    onQueryChanged: billsResults.refresh()

    Bill {
        id: current
        // non user interactive properties
        StateSaver.properties: "billId, date"

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

    U1db.Index {
        database: db
        id: allIndex
        /* You have to specify in the index all fields you want to retrieve
           The query should return the whole document, not just indexed fields
           https://bugs.launchpad.net/u1db-qt/+bug/1271973 */
        expression: current.billSavedProperties
    }

    /*
     * Use a query instead of getDocs() or directly use the db of model as deleted docs would still be listed otherwise.
     * See bug https://bugs.launchpad.net/u1db-qt/+bug/1219862
     */
    U1db.Query {
        id: all
        index: allIndex
        onResultsChanged: billsResults.refresh()
    }

    /*
     * Create a new model with filter capability as
     * This is not optimized, but it's a QML workaround for now as Query can't match multiple "or" elements or
     * search with *foo (only foo* is supported) and FilterSortItem doesn't support filter.property = "contents.title"
     * on a subelements. Also, it can't sort and filter at the same time
     * https://launchpad.net/bugs/1488821, https://launchpad.net/bugs/1488822, https://launchpad.net/bugs/1488823.
     */
    ListModel {
        id: billsResults

        function refresh() {
            // avoid multiple queries at startup when the worker isn't ready
            if (!queryWorker.ready)
                return
            queryWorker.sendMessage({'all': all.results, 'model': billsResults, 'query': query})
        }
    }

    WorkerScript {
        id: queryWorker
        property bool ready: false
        source: "queryworker.js"

        Component.onCompleted: { ready = true; billsResults.refresh(); }
    }

    AttachmentStore {
        id: attachmentStore
    }

    function saveCurrent() {
        // create a new docID if not saved already
        if (!current.billId)
            current.billId = Date.now();

        var tosave = current.toJson();

        // WORKAROUND FOR: https://launchpad.net/bugs/1482504
        // We shift the date by the time difference so that the date is directly in UTC
        // (which is what is saved by putDoc)
        tosave["date"] = new Date(tosave["date"].getTime() + tosave["date"].getTimezoneOffset() * 60000)
        tosave["currencyFetchDate"] = new Date(tosave["currencyFetchDate"].getTime() + tosave["currencyFetchDate"].getTimezoneOffset() * 60000)

        return db.putDoc(tosave, current.billId) !== "-1";
    }

    function deleteBill(docId) {
        attachmentStore.purge(docId);
        db.deleteDoc(docId);

        // if current Bill as well, reset it
        if (current.billId === docId)
            current.reset();
    }
}
