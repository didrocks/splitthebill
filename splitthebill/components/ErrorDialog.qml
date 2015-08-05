import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0

Component {
    Dialog {
        id: errorDialog

        Button {
            text: i18n.tr("Close")
            color: UbuntuColors.red
            onClicked: PopupUtils.close(errorDialog)
        }
    }
}

