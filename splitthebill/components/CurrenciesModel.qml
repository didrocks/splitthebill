import QtQuick 2.4

Component {
    ListModel {

        // COMMENT: we are going to fetch the actual data from the Euro foreign exchange reference rates from the European
        // Central Bank. As such, the Euro itself is not defined there, so we’ll pre-populate our list with the EUR
        // currency, with a reference rate of 1.0.
        ListElement {
            currency: "EUR"
            rate: 1.0
        }
    }
}
