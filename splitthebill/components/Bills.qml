import QtQuick 2.4
import U1db 1.0 as U1db
import Ubuntu.Components 1.2

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
     * on a subelement
     */
    ListModel {
        id: billsResults

        function refresh() {
            billsResults.clear();
            // docID isn't part of results(), that's why we added billId.
            for (var index in all.results) {
                // if there is a query, search on all fields to decide or not to include the elem
                var currentElem = all.results[index];
                if (handler.query) {
                    var include = false;
                    var regex = new RegExp(handler.query, 'i')
                    for (var prop in all.results[index]) {
                        if (prop === "billId")
                            continue;
                        if (currentElem[prop].toString().match(regex)) {
                            include = true;
                            break;
                        }
                    }
                    if(!include)
                        continue;
                }
                // add as well helpers for section and sorting:
                var elemDate = new Date(currentElem.date);
                currentElem['monthSection'] = elemDate.toLocaleString(Qt.locale(),  "MMMM yyyy");
                currentElem['yearSection'] = elemDate.getFullYear();
                currentElem['timestamp'] = elemDate.getTime();

                billsResults.append(currentElem);
            }
        }
    }

    function saveCurrent() {
        // create a new docID if not saved already
        if (!current.billId)
            current.billId = Date.now();
        return db.putDoc(current.toJson(), current.billId) !== "-1";
    }

    function deleteBill(docId) {
        db.deleteDoc(docId);

        // if current Bill as well, reset it
        if (current.billId === docId)
            current.reset();
    }
}
