import QtQuick 2.4

QtObject {
    property string title
    property string rawBill
    property int tipShare
    property int numTotalPeople
    property int numSharePeople
    property date date

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
}
