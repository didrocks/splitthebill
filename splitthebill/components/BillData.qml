import QtQuick 2.4

Item {
    property double bill
    property int tipShare
    property int numTotalPeople
    property int numSharePeople

    property double totalTip: bill * tipShare / 100
    property double totalBill: bill + totalTip
    property double _sharePercent: numSharePeople / numTotalPeople
    property double shareTip: _sharePercent * totalTip
    property double shareBill: _sharePercent * totalBill
}
