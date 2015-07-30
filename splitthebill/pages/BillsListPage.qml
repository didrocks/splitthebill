import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

import "../components"

PageWithBottomEdge {
    id: billsList
    property QtObject billsHandler
    property bool animationEnded: false

    title: "Split the bill"
    reloadBottomEdgePage: false

    // don't show elements under the header
    clip: true

    UbuntuListView {

        height: parent.height
        anchors {
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
            left: parent.left
            right: parent.right
        }

        model: billsHandler.all
        delegate: BillListItem {
            billsHandler: billsList.billsHandler
        }
    }

    bottomEdgeTitle: "Add new"
    bottomEdgePageComponent: BillEditPage {
        id: billEditPage
        title: "New/Edit bill"
        billsHandler: billsList.billsHandler
    }
}
