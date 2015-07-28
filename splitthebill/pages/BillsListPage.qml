import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Ubuntu.Components.Themes.Ambiance 1.0

import "../components"

UbuntuListView{

    height: units.gu(100)
    anchors {
        leftMargin: units.gu(2)
        rightMargin: units.gu(2)
        left: parent.left
        right: parent.right
    }

    model: billsHandler.all
    delegate: BillListItem {
        billsHandler: billsHandler
    }
}

