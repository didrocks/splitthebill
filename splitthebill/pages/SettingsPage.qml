import QtQuick 2.4
import Qt.labs.settings 1.0

import Ubuntu.Components 1.2

import "../components"

Page {
    id: root
    title: "Settings"

    property bool _readyBindSettings: false

    // we want a fixed header
    flickable: null
    Flickable {
        id: settingsFlickable
        anchors.fill: parent
        contentHeight: childrenRect.height

        clip: true

        Column {
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            OptionSelector {
                id: separatorSelector
                text: i18n.tr("Divide on:")
                model: [AppSettings.sSEPARATIONTYPENAME.month, AppSettings.sSEPARATIONTYPENAME.year,
                        AppSettings.sSEPARATIONTYPENAME.none]
                Binding on selectedIndex { value: AppSettings.billSeparationType }
                Binding {
                    target: AppSettings
                    property: "billSeparationType"
                    value: separatorSelector.selectedIndex
                    when: _readyBindSettings
                }
            }

            /* workaround for https://launchpad.net/bugs/1481624 */
            Label {
                text: " "
            }
        }
    }
    // only bind settings now as the OptionSelector is setting default and retrigger binding
    Component.onCompleted: _readyBindSettings = true
}
