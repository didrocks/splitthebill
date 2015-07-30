import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

import "../components"

PageWithBottomEdge {
    id: billsList
    property QtObject billsHandler

    title: "Split the bill"
    reloadBottomEdgePage: false

    // reset current bottom edge Bill on released
    onBottomEdgeDismissed: { billsHandler.current.reset(); }

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

    Item {
        anchors.fill: parent
        visible: billsHandler.all.len === 0

        Icon {
            id: emptyStateIcon
            anchors.fill: parent
            anchors.horizontalCenter: emptyStateLabel.horizontalCenter
            opacity: 0.3
            name: "notebook"
        }

        Label {
            id: emptyStateLabel
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: "No bills have been archived"
            color: "#5d5d5d"
            fontSize: "x-large"
            wrapMode: Text.WordWrap
        }
    }

    bottomEdgeTitle: "Add new"
    bottomEdgePageComponent: BillEditPage {
        id: billEditPage
        title: billsHandler.current.billId ? "Edit bill" : "New bill"
        billsHandler: billsList.billsHandler
    }
}
