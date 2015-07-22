import QtQuick 2.4
import Ubuntu.Components 1.2

Row {
    id: main
    spacing: units.gu(1)

    property int defaultValue
    property int min: 0
    property int max: 99
    property alias text: label.text
    property alias currentValue: num.currentValue

    Label {
        id: label
        verticalAlignment: Text.AlignVCenter
        height: parent.height
        width: units.gu(16) // TODO: fix this for i18n
    }
    function setCurrentValueBinding() {
        num.currentValue = Qt.binding(function() { return Math.min(num.currentValue, max) });
    }

    Row {
        Button {
            iconName: "remove"
            width: height
            enabled: num.text > min
            onClicked: { num.currentValue--; setCurrentValueBinding(); }
        }
        TextField {
            id: num
            horizontalAlignment: TextInput.AlignHCenter
            text: currentValue
            property int currentValue: { setCurrentValueBinding(); }
            maximumLength: 2
            readOnly: true
            width: units.gu(5)
        }
        Button {
            iconName: "add"
            width: height
            enabled: num.text < max
            onClicked: { num.currentValue++; setCurrentValueBinding(); }
        }
    }
}
