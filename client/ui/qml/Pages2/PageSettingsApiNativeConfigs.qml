import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QtCore

import SortFilterProxyModel 0.2

import PageEnum 1.0
import Style 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"
import "../Components"

PageType {
    id: root

    property string configExtension: ".conf"
    property string configCaption: qsTr("Save AmneziaVPN config")

    ListViewType {
        id: listView

        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 24

        model: ApiCountryModel

        header: ColumnLayout {
            width: listView.width

            BackButtonType {
                id: backButton
            }

            HeaderType {
                id: header

                Layout.fillWidth: true
                Layout.rightMargin: 16
                Layout.leftMargin: 16

                headerText: qsTr("Configuration files")
                descriptionText: qsTr("To connect a router or AmneziaWG application")
            }
        }

        delegate: ColumnLayout {
            width: listView.width

            LabelWithButtonType {
                id: telegramButton
                Layout.fillWidth: true
                Layout.topMargin: 6

                text: countryName
                leftImageSource: "qrc:/countriesFlags/images/flagKit/" + countryImageCode + ".svg"
                rightImageSource: "qrc:/images/controls/download.svg"

                clickedFunction: function() {
                    var fileName = ""
                    if (GC.isMobile()) {
                        fileName = countryCode + configExtension
                    } else {
                        fileName = SystemController.getFileName(configCaption,
                                                                qsTr("Config files (*" + configExtension + ")"),
                                                                StandardPaths.standardLocations(StandardPaths.DocumentsLocation) + "/" + countryCode,
                                                                true,
                                                                configExtension)
                    }
                    if (fileName !== "") {
                        PageController.showBusyIndicator(true)
                        let result = ApiConfigsController.exportNativeConfig(countryCode, fileName)
                        PageController.showBusyIndicator(false)

                        if (result) {
                            PageController.showNotificationMessage(qsTr("Config file saved"))
                        }
                    }
                }
            }

            DividerType {}
        }
    }
}
