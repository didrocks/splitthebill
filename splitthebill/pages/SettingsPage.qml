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
        contentHeight: layout.height

        clip: true

        Column {
            id: layout
            spacing: units.gu(3)
            height: childrenRect.height
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            // bug without Label height: childrenRect.height doesn't work for flickable
            Label {
                id: label1
                text: "foo"
            }

            // TO ASK: why?
            OptionSelector {
                id: separatorSelector
                text: "Separation:"
                model: [AppSettings.sSEPARATIONTYPENAME.month, AppSettings.sSEPARATIONTYPENAME.year,
                        AppSettings.sSEPARATIONTYPENAME.none]
                Binding on selectedIndex { value: AppSettings.billSeparationType }
                Binding {
                    target: AppSettings
                    property: "billSeparationType"
                    value: separatorSelector.selectedIndex
                    when: _readyBindSettings
                }
            }            /*
            OptionSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }
            OptionSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }
            OptionSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }
            OptionSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }
            OptionSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }
            OptionSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }
            OptionSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }
            OptionSelector {
                text: i18n.tr("Label")
                model: [i18n.tr("Value 1"),
                        i18n.tr("Value 2"),
                        i18n.tr("Value 3"),
                        i18n.tr("Value 4")]
            }*/
        }
    }
    // only bind settings now as the OptionSelector is setting default and retrigger binding
    Component.onCompleted: _readyBindSettings = true
}
