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
      // TRANSLATORS: separation bills string
      property string month: i18n.tr("Month")
      // TRANSLATORS: separation bills string
      property string year: i18n.tr("Year")
      // TRANSLATORS: separation bills string
      property string none: i18n.tr("None")
    }

    Settings {
        id: settings
        property int billSeparationType
    }
}
