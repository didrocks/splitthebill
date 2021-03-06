import QtQuick 2.4
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0

import Ubuntu.Components 1.2

import "../components"

Page {
    id: root
    title: "Settings"

    property QtObject billsHandler

    property bool _readyBindSettings: false

    // we want a fixed header
    flickable: null
    Flickable {
        id: settingsFlickable
        anchors.fill: parent
        contentHeight: childrenRect.height
        // COMMENT: show clip
        clip: true

        Column {
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }
            spacing: units.gu(1)

            OptionSelector {
                id: separatorSelector
                text: i18n.tr("Divide list on:")
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

            OptionSelector {
                id: preferredCurrencySelector
                text: i18n.tr("Preferred currency:")
                model: billsHandler.current.currencies
                delegate: OptionSelectorDelegate { text: currency }
                Binding on selectedIndex { value: AppSettings.preferredCurrencyIndex }
                Binding {
                    target: AppSettings
                    property: "preferredCurrencyIndex"
                    value: preferredCurrencySelector.selectedIndex
                    when: _readyBindSettings
                }
            }

            RowLayout {
                anchors { left: parent.left; right: parent.right }

                Label {
                    Layout.fillWidth: true
                    text: i18n.tr("Location support")
                }

                Switch {
                    id: useLocationSwitch
                    checked: AppSettings.useLocation
                    Binding {
                        target: AppSettings
                        property: "useLocation"
                        value: useLocationSwitch.checked
                        when: _readyBindSettings
                    }
                }
            }

            Label {
                anchors { left: parent.left; right: parent.right }
                text: AppSettings.positionErrorMsg
                fontSize: "small"
                color: UbuntuColors.red
                wrapMode: Text.WordWrap
            }

            RowLayout {
                anchors { left: parent.left; right: parent.right }

                Label {
                    Layout.fillWidth: true
                    text: i18n.tr("Use Dark theme")
                }

                Switch {
                    id: useDarkThemeSwitch
                    checked: AppSettings.useDarkTheme
                    Binding {
                        target: AppSettings
                        property: "useDarkTheme"
                        value: useDarkThemeSwitch.checked
                        when: _readyBindSettings
                    }
                }
            }
        }
    }
    // only bind settings now as the OptionSelector is setting default and retrigger binding
    Component.onCompleted: _readyBindSettings = true
}
