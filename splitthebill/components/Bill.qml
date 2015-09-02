import QtQuick 2.4

// Need to import current dir for AppSettings: https://launchpad.net/bugs/1488782
import "."
import "../tools.js" as Tools

Item {
    id: self

    property string billId
    property string title
    property date date
    property string rawBill
    property int tipShare
    property int numTotalPeople
    property int numSharePeople
    property string comments
    // we use directly a ListModel as a list of Strings is automatically transtyped as such by any attached property
    // to a model
    property ListModel attachments: newListModel.createObject(parent)
    property int billCurrencyIndex
    property date currencyFetchDate
    property ListModel currencies: newCurrenciesModel.createObject(parent)

    property var billSavedProperties: ["billId", "title", "date", "rawBill", "tipShare", "numTotalPeople",
                                       "numSharePeople", "comments", "attachments",
                                       "billCurrencyIndex", "currencies", "currencyFetchDate"]

    readonly property double bill: {
        var value = parseFloat(Tools.normalizeNum(rawBill));
        /* check if value is NaN, as QMl doesn't support emacsript 6.
           A Nan number isn't equals to itself.
           More info at http://adripofjavascript.com/blog/drips/the-problem-with-testing-for-nan-in-javascript.html */
        if (value !== value)
            return 0;
        return value;
    }
    readonly property double totalTip: bill * tipShare / 100
    readonly property double totalBill: bill + totalTip
    readonly property double _sharePercent: numSharePeople / numTotalPeople
    readonly property double shareTip: _sharePercent * totalTip
    readonly property double shareBill: _sharePercent * totalBill
    /* COMMENT: present translators comment in i18n */
    // TRANSLATORS: %1 is the date of the current bill, %2 is the time of the current bill
    readonly property string formattedDate: i18n.tr("%1 - %2").arg(date.toLocaleDateString()).arg(date.toLocaleTimeString())
    // COMMENT: here is how to handle plural form
    readonly property string summary: i18n.tr("You paid the totally (1 person).",
                                              "You paid for %1 out of %2 persons.".arg(numSharePeople).arg(numTotalPeople),
                                              numTotalPeople)
    readonly property string shortSummaryShare: inForeignCurrency ?
                                                    //TRANSLATORS: %1 is the share bill, %2 the currency it was paid in, %3 an indication in the pref currency, %4 the pref currency name and %5 the date it was paid in
                                                    i18n.tr("I paid the totally (1 person) for %1 %2 (%3 %4) on the %5"
                                                        .arg(shareBill).arg(billCurrencyName)
                                                        .arg(shareBillInPrefCurrency).arg(prefCurrencyName)
                                                        .arg(formattedDate),
                                                        "I paid for %1 out of %2 persons for %3 %4 (%5 %6) on the %7"
                                                        .arg(numSharePeople).arg(numTotalPeople)
                                                        .arg(shareBill).arg(billCurrencyName)
                                                        .arg(shareBillInPrefCurrency).arg(prefCurrencyName)
                                                        .arg(formattedDate),
                                                        numTotalPeople) :
                                                    i18n.tr("I paid the totally (1 person) for %1 %2 on the %5"
                                                        .arg(shareBill).arg(billCurrencyName)
                                                        .arg(formattedDate),
                                                        "I paid for %1 out of %2 persons for %3 %4 on the %7"
                                                        .arg(numSharePeople).arg(numTotalPeople)
                                                        .arg(shareBill).arg(billCurrencyName)
                                                        .arg(formattedDate),
                                                        numTotalPeople)

    readonly property string summaryShare: i18n.tr("Date: %1\n").arg(formattedDate) +
                                           i18n.tr("I paid the totally (1 person)\n",
                                                   "I paid for %1 out of %2 persons\n".arg(numSharePeople).arg(numTotalPeople),
                                                   numTotalPeople) +
                                           inForeignCurrency ?
                                           //TRANSLATORS: %1 is a price, %2 the currency it was paid in, %3 the total bill in pref currency, and %4 the pref currency
                                           i18n.tr("Paid: %1 %2 (%3 %4)\n").arg(shareBill).arg(billCurrencyName)
                                           .arg(shareBillInPrefCurrency).arg(prefCurrencyName) :
                                           i18n.tr("Paid: %1 %2\n").arg(shareBill).arg(billCurrencyName) +
                                           i18n.tr("Tip: %1%\n\n").arg(tipShare) +
                                           (comments ? i18n.tr("Additional notes: %1").arg(comments) : '');
    readonly property bool inForeignCurrency: billCurrencyName !== prefCurrencyName
    // COMMENT: billCurrencyIndex might be restored before currencies
    readonly property string billCurrencyName: currencies ? currencies.get(billCurrencyIndex).currency : ""
    readonly property string prefCurrencyName: currencies ? currencies.get(AppSettings.preferredCurrencyIndex).currency : ""
    readonly property double _exchangeRate: currencies ? currencies.get(AppSettings.preferredCurrencyIndex).rate /
                                            currencies.get(billCurrencyIndex).rate : 1.0
    readonly property double totalBillInPrefCurrency: totalBill * _exchangeRate
    readonly property double shareBillInPrefCurrency: shareBill * _exchangeRate

    NewListModel {
        id: newListModel
    }

    CurrenciesModel {
        id: newCurrenciesModel
    }

    /* load from json or dictionary compatible objects */
    // this show that qml property can be accessed with object["name"] or object.name
    function loadFromJson(billJson) {
        // assign all properties from this element
        for (var index in billSavedProperties) {
            var prop = billSavedProperties[index];
            // COMMENT: be future proof when removing properties
            if (billJson[prop])
                self[prop] = billJson[prop];
        }
    }

    function toJson() {
        var returnJson = {};
        for (var index in billSavedProperties) {
            var prop = billSavedProperties[index];
            /* WORKAROUND:
             * assigning a list of anything as a property in a model makes it a QMLListModel. We want for our
             * Bill object to still have a list of json objects for storing in u1db
             * https://bugs.launchpad.net/ubuntu/+source/u1db-qt/+bug/1483614
             */
            if (self[prop].toString().indexOf("QQmlListModel") === 0) {
                var listResult = [];
                for (var i = 0; i < self[prop].count; i++) {
                    var elem = self[prop].get(i);
                    var jsonToStore = {};
                    /*
                     * transform a ModelObject to json:
                     * - we can't store in u1db a ModelObject directly, it will store null
                     * - there is no trivial function to achieve it (so having to parse it after stringifying it)
                     * - we want to be flexible and not knowing in advance the properties that can get out of it
                     */
                    var jsonElem = JSON.parse(JSON.stringify(elem));
                    for (var propElem in jsonElem) {
                        // we don't store the objectName
                        if (propElem === "objectName")
                            continue;
                        jsonToStore[propElem] = jsonElem[propElem];
                    }
                    listResult.push(jsonToStore);
                }
                returnJson[prop] = listResult;
            } else
                returnJson[prop] = self[prop];
        }
        return returnJson;
    }

    function reset() {
        billId = "";
        title = "";
        date = new Date();
        rawBill = "";
        tipShare = 15;
        numTotalPeople = 2;
        numSharePeople = 1;
        // TRANSLATORS: %1 is default addition to comment if we detected a location
        comments = AppSettings.useLocation && AppSettings.currentLocation ?
                    i18n.tr("(in %1)").arg(AppSettings.currentLocation) : "";
        attachments = newListModel.createObject(parent);
        currencies = newCurrenciesModel.createObject(parent);
        currencyFetchDate = new Date();
        billCurrencyIndex = AppSettings.preferredCurrencyIndex;
    }
}
