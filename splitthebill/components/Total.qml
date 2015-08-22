import QtQuick 2.0
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

// This is how javascript is imported
import "../tools.js" as Tools

Item {

    property bool hilight: false
    property alias label: labelPrefix.text
    property double mainValue
    property double mainValuePrefCurrency
    property double tipValue
    property string currencyName
    property string prefCurrencyName

    // set a higher height than the one from the children
    height: units.gu(5)
    clip: true

    states: State {
        when: hilight

        // visible: !hilight
        // then, show the state which is better than binding as we change a bunch of properties
        PropertyChanges { target: hilightRect; visible: true }
        PropertyChanges { target: labelPrefix; color: "white" }
        PropertyChanges { target: mainText; color: UbuntuColors.darkAubergine }
        PropertyChanges { target: mainText; font.pixelSize: units.gu(2) }
        PropertyChanges { target: mainText; font.weight: Font.Bold }
    }

    // TODO: UbuntuShape force width == height
    Rectangle {
        id: hilightRect
        anchors.fill: parent
        visible: false
        radius: units.gu(1)
        gradient: UbuntuColors.orangeGradient
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
        }

        RowLayout {
            Layout.preferredWidth: parent.width / 2
            Layout.maximumWidth: parent.width / 2
            clip: true

            Label { id: labelPrefix }

            Text {
                id: mainText
                horizontalAlignment: Text.AlignHCenter
                // TRANSLATORS: %1 is price in bill currency, %2 is bill currency name, %3 is conversion in pref currency, %4 is pref currency name
                text: i18n.tr("%1 %2 (%3 %4)").arg(Tools.displayNum(mainValue)).arg(currencyName)
                                              .arg(mainValuePrefCurrency).arg(prefCurrencyName)
                elide: Text.ElideRight
            }
        }

        Text {
            Layout.preferredWidth: parent.width / 2
            Layout.maximumWidth: parent.width / 2
            horizontalAlignment: Text.AlignHCenter
            // TRANSLATORS: %1 is paid tip in bill currency, %2 is bill currency name
            text: i18n.tr("(incl. tip: %1 %2)").arg(Tools.displayNum(tipValue)).arg(currencyName)
            elide: Text.ElideRight
        }
    }
}
