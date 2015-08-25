pragma Singleton
import QtQuick 2.4
import Qt.labs.settings 1.0
import QtPositioning 5.2
import QtLocation 5.3
import Ubuntu.Components 1.2

Item {
    property alias billSeparationType: settings.billSeparationType
    property alias preferredCurrencyIndex: settings.preferredCurrencyIndex
    property alias useLocation: settings.useLocation
    property alias currentLocation: settings.currentLocation
    property alias useDarkTheme: settings.useDarkTheme

    property alias positionErrorMsg: positionSource.errormsg

    property alias sSEPARATIONTYPE: separationType
    property alias sSEPARATIONTYPENAME: separationTypeName

    property string _defaultTheme

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

    Plugin {
        id: osmPlugin
        name: "osm"
    }

    PositionSource {
        id: positionSource
        active: useLocation
        property string errormsg
        updateInterval: 120000 // 2 mins
        onPositionChanged: {
            var coord = positionSource.position.coordinate;
            console.log("OOOOOOOOOOOOOOOOOOO " + coord + " is valid: " + coord.isValid)
            // that probably means latitude and longitude are nan, assume the permission was denied (bug URL…)
            if (!coord.isValid) {
                errormsg = i18n.tr("We couldn't get your location yet. You should check in system settings the application permissions.")
                return;
            }
            if (coord.isValid && geocodeModel.query !== coord) {
                errormsg = "";
                geocodeModel.query = coord;
                geocodeModel.update();
            }
        }
    }

    GeocodeModel {
        id: geocodeModel
        autoUpdate: false
        plugin: osmPlugin
        limit: 1

        onCountChanged: {
            // Update the currentLocation if one is found and it does not match the stored location
            if (count > 0) {
                settings.currentLocation = geocodeModel.get(0).address.city
            }
        }
    }

    Settings {
        id: settings
        property int billSeparationType
        property int preferredCurrencyIndex
        property bool useLocation
        property string currentLocation
        property bool useDarkTheme
        onUseDarkThemeChanged: {
            if (!_defaultTheme)
                _defaultTheme = Theme.name
            if (useDarkTheme)
                Theme.name = "Ubuntu.Components.Themes.SuruDark";
            else
                Theme.name = _defaultTheme;
        }
    }
}
