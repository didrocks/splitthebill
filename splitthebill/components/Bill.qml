import QtQuick 2.4

QtObject {
    property string billId
    property string title
    property date date
    property string rawBill
    property int tipShare
    property int numTotalPeople
    property int numSharePeople

    readonly property double bill: {
        var value = parseFloat(rawBill.replace(',', '.'));
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

    /* load from json or dictionary compatible objects */
    // this show that qml property can be accessed with object["name"] or object.name
    function loadFromJson(billJson) {
        // assign all properties from this element
        billId = billJson["billId"];
        title = billJson["title"];
        date = billJson["date"];
        rawBill = billJson["rawBill"];
        tipShare = billJson["tipShare"];
        numTotalPeople = billJson["numTotalPeople"];
        numSharePeople = billJson["numSharePeople"];
    }

    function toJson() {
        return {
            'title': title,
            'date': date,
            'rawBill': rawBill,
            'tipShare': tipShare,
            'numTotalPeople': numTotalPeople,
            'numSharePeople': numSharePeople
        }
    }

    function reset() {
        // this disable autosave first
        billId = "";
        title = "";
        date = new Date();
        rawBill = "";
        tipShare = 15;
        numTotalPeople = 2;
        numSharePeople = 1;
    }
}
