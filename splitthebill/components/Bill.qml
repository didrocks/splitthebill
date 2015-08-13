import QtQuick 2.4

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

    property var billSavedProperties: ["billId", "title", "date", "rawBill", "tipShare", "numTotalPeople",
                                       "numSharePeople", "comments", "attachments"]

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
    readonly property string formattedDate: date.toLocaleDateString() + " - " + date.toLocaleTimeString()
    readonly property string shortSummaryShare: i18n.tr("I paid the totally (1 person) for $%1 on the %2".arg(shareBill).arg(formattedDate),
                                                        "I paid for %1 out of %2 persons for $%3 on the %4".arg(numSharePeople).arg(numTotalPeople).arg(shareBill).arg(formattedDate),
                                                        numTotalPeople)

    readonly property string summaryShare: i18n.tr("Date: %1\n").arg(formattedDate) +
                                           i18n.tr("I paid the totally (1 person)\n",
                                                   "I paid for %1 out of %2 persons\n".arg(numSharePeople).arg(numTotalPeople),
                                                   numTotalPeople) +
                                           i18n.tr("Paid: $%1\n").arg(shareBill) +
                                           i18n.tr("Tip: %1%\n\n").arg(tipShare) +
                                           (comments ? i18n.tr("Additional notes: %1").arg(comments) : '');

    NewListModel {
        id: newListModel
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
        comments = "";
        attachments = newListModel.createObject(parent);
    }
}
