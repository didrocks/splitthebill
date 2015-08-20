import QtQuick 2.4

Component {
    ListModel {
        property date fetchedOn

        // COMMENT: we are going to fetch the actual data from the Euro foreign exchange reference rates from the European
        // Central Bank. As such, the Euro itself is not defined there, so we’ll pre-populate our list with the EUR
        // currency, with a reference rate of 1.0.
        ListElement {
            currency: "EUR"
            rate: 1.0
        }

        function getCurrency(idx) {
            return (idx >= 0 && idx < count) ? get(idx).currency: ""
        }

        function getRate(idx) {
            return (idx >= 0 && idx < count) ? get(idx).rate: 0.0
        }

        function convert(from, fromRateIndex, toRateIndex) {
            var fromRate = currencies.getRate(fromRateIndex);
            if (from.length <= 0 || fromRate <= 0.0)
                return "";
            return currencies.getRate(toRateIndex) * (parseFloat(from) / fromRate);
        }
    }
}
