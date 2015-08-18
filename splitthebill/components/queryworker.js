WorkerScript.onMessage = function(msg) {
    var billsResults = msg.model;
    var allresults = msg.all;
    var query = msg.query

    billsResults.clear();
    // docID isn't part of results(), that's why we added billId.
    for (var index in allresults) {
        // if there is a query, search on all fields to decide or not to include the elem
        var currentElem = allresults[index];
        if (query) {
            var include = false;
            var regex = new RegExp(query, 'i')
            for (var prop in allresults[index]) {
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
    billsResults.sync();   // updates the changes to the list
}
