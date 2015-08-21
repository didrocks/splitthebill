import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0

// TODO: open a bug on why we can do height: page.height if in the same QML page, but not in a separate file when using a component
Component {
    id: currencySelector
    Popover {
        id: popover
        property var bill
        Column {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            Header {
                id: header
                text: i18n.tr("Select currency (refreshed on %1)").arg(bill.currencyFetchDate.toLocaleString(Qt.locale(),  "dd-MM-yyyy"))
            }
            UbuntuListView {
                clip: true
                width: parent.width
                height: popover.height
                model: popover.bill.currencies
                delegate: ListItem {
                    Label {
                        // TRANSLATORS: %1 is currency name, %2 is the rate
                        text: i18n.tr("%1 (%2)").arg(currency).arg(rate)
                    }
                    onClicked: {
                        // COMMENT: show the caller to update caller property
                        caller.currencyIndex = index
                        hide()
                    }
                }
            }
        }
    }
}
