import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Ubuntu.Components.Themes.Ambiance 1.0

import "../components"

UbuntuListView{
    // TASK: why needing to set a height and width?
    height: units.gu(80)

    anchors {
        leftMargin: units.gu(2)
        rightMargin: units.gu(2)
        fill: parent
    }

    model: billsHandler.all
    delegate: BillListItem {
        billsHandler: billsHandler
    }
}

