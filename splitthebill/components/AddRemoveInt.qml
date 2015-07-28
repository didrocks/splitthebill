import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

RowLayout {
    spacing: units.gu(1)

    property int defaultValue
    property int min: 0
    property int max: 99
    property alias text: label.text
    property alias currentValue: num.currentValue

    property QtObject modelid
    property string modelPropertyName
    Binding on currentValue { value: modelid[modelPropertyName] }
    Binding {
        target: modelid
        property: modelPropertyName
        value: currentValue
    }

    Label {
        id: label
        verticalAlignment: Text.AlignVCenter
        Layout.fillWidth: true
    }
    function setCurrentValueBinding() {
        num.currentValue = Qt.binding(function() { return Math.min(num.currentValue, max) });
    }

    // use case: total number of people on another component is decreased twice
    // (and QUESTION: max doesn't seem to be the binding here, but the value)
    // good introduced on property changed
    onMaxChanged: setCurrentValueBinding();

    Button {
        iconName: "remove"
        enabled: num.text > min
        onClicked: { num.currentValue--; setCurrentValueBinding(); }
        Layout.maximumWidth: height
    }
    TextField {
        id: num
        horizontalAlignment: TextInput.AlignHCenter
        text: currentValue
        property int currentValue: { setCurrentValueBinding(); }
        maximumLength: 2
        readOnly: true
        Layout.preferredWidth: units.gu(5)
    }
    Button {
        iconName: "add"
        enabled: num.text < max
        onClicked: { num.currentValue++; setCurrentValueBinding(); }
        Layout.maximumWidth: height
    }
}
