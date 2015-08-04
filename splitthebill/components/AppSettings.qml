pragma Singleton
import QtQuick 2.4
import Qt.labs.settings 1.0

Item {
    property alias billSeparationType: settings.billSeparationType

    property alias sSEPARATIONTYPE: separationType
    property alias sSEPARATIONTYPENAME: separationTypeName

    QtObject {
      id: separationType
      property int month: 0
      property int year: 1
      property int none: 2
    }
    QtObject {
      id: separationTypeName
      property string month: "Month"
      property string year: "Year"
      property string none: "None"
    }

    Settings {
        id: settings
        property int billSeparationType
    }
}
