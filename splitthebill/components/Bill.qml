import QtQuick 2.4

Item {
    property string title
    property string rawBill
    property int tipShare
    property int numTotalPeople
    property int numSharePeople

    property double bill: {
        var value = parseFloat(rawBill.replace(',', '.'));
        /* check if value is NaN, as QMl doesn't support emacsript 6.
           A Nan number isn't equals to itself.
           More info at http://adripofjavascript.com/blog/drips/the-problem-with-testing-for-nan-in-javascript.html */
        if (value !== value)
            return 0;
        return value;
    }
    property double totalTip: bill * tipShare / 100
    property double totalBill: bill + totalTip
    property double _sharePercent: numSharePeople / numTotalPeople
    property double shareTip: _sharePercent * totalTip
    property double shareBill: _sharePercent * totalBill
}
