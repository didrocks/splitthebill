import QtQuick 2.0
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

// This is how javascript is imported
import "../tools.js" as Tools

RowLayout {

    property bool hilight: false
    property alias label: labelPrefix.text
    property double mainValue
    property double tipValue

    // set a higher height than the one from the children
    height: units.gu(5)
    clip: true

    states: State {
        when: hilight

        // do this first, see that the items are not align, so change the opacity
        //visible: hilight

        // FIXME: this is a bit of a hack, but didn't find any other way to align the 2 "Total" and "You pay" text
        // opacity: if (!hilight) 0, or opacity: if (!hilight) 0 : opacity
        // then, show the assign [undefinied] and then the binding loop and use the State (inversing the opacity to 1)
        PropertyChanges { target: hilightRect; opacity: 1 }
        PropertyChanges { target: labelPrefix; color: "white" }
        PropertyChanges { target: mainText; color: UbuntuColors.darkAubergine }
        PropertyChanges { target: mainText; font.pixelSize: units.gu(2) }
        PropertyChanges { target: mainText; font.weight: Font.Bold }
    }

    // TODO: UbuntuShape force width == height
    Rectangle {
        id: hilightRect
        radius: units.gu(1)
        gradient: UbuntuColors.orangeGradient
        anchors {
            fill: parent
        }
        opacity: 0
    }

    RowLayout {
        height: parent.height
        Layout.preferredWidth: parent.width / 2
        Layout.maximumWidth: parent.width / 2
        clip: true
        Label {
            id: labelPrefix
        }
        Text {
            id: mainText
            Layout.maximumWidth: parent.width - labelPrefix.width
            text: Tools.displayNum(mainValue) + " $"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }
    Text {
        Layout.preferredWidth: parent.width / 2
        Layout.maximumWidth: parent.width / 2
        text: "(incl. tip: " + Tools.displayNum(tipValue) + " $)"
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }
}
