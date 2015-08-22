import QtQuick 2.4
import QtQuick.XmlListModel 2.0

Item {
    property var bill

    XmlListModel {
        id: modelFetcher
        source: "http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml"
        namespaceDeclarations: "declare namespace gesmes='http://www.gesmes.org/xml/2002-08-01';"
                               + "declare default element namespace 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref';"
        query: "/gesmes:Envelope/Cube/Cube/Cube"

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                for (var i = 0; i < count; i++)
                    bill.currencies.append({"currency": get(i).currency, "rate": parseFloat(get(i).rate)})
                bill.currencyFetchDate = new Date();
            }
        }
        XmlRole { name: "currency"; query: "@currency/string()" }
        XmlRole { name: "rate"; query: "@rate/string()" }
    }

    Connections {
        target: bill
        onCurrenciesChanged: {
            // refetch currencies for any new model
            if (!bill.billId)
                modelFetcher.reload();
        }
    }
}
