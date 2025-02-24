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
                Layout.fillWidth: true
                Layout.topMargin: 6

                text: countryName
                leftImageSource: "qrc:/countriesFlags/images/flagKit/" + countryImageCode + ".svg"
                rightImageSource: isIssued ? "qrc:/images/controls/more-vertical.svg" : "qrc:/images/controls/download.svg"

                clickedFunction: function() {
                    if (isIssued) {
                        moreOptionsDrawer.countryName = countryName
                        moreOptionsDrawer.countryCode = countryCode
                        moreOptionsDrawer.openTriggered()
                    } else {
                        issueConfig(countryCode)
                    }
                }
            }

            DividerType {}
        }
    }

    DrawerType2 {
        id: moreOptionsDrawer

        property string countryName
        property string countryCode

        anchors.fill: parent
        expandedHeight: parent.height * 0.4375

        expandedStateContent: Item {
            implicitHeight: moreOptionsDrawer.expandedHeight

            BackButtonType {
                id: moreOptionsDrawerBackButton

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 16

                backButtonFunction: function() {
                    moreOptionsDrawer.closeTriggered()
                }
            }

            FlickableType {
                anchors.top: moreOptionsDrawerBackButton.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                contentHeight: moreOptionsDrawerContent.height

                ColumnLayout {
                    id: moreOptionsDrawerContent

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Header2Type {
                        Layout.fillWidth: true
                        Layout.margins: 16

                        headerText: qsTr("Configuration file ") + moreOptionsDrawer.countryName
                    }

                    LabelWithButtonType {
                        Layout.fillWidth: true

                        text: qsTr("Create a new")
                        descriptionText: qsTr("The previously created one will stop working")

                        clickedFunction: function() {
                            showQuestion(true, moreOptionsDrawer.countryCode, moreOptionsDrawer.countryName)
                        }
                    }

                    DividerType {}

                    LabelWithButtonType {
                        Layout.fillWidth: true
                        text: qsTr("Revoke the current configuration file")

                        clickedFunction: function() {
                            showQuestion(false, moreOptionsDrawer.countryCode, moreOptionsDrawer.countryName)
                        }
                    }

                    DividerType {}
                }
            }
        }
    }

    function issueConfig(countryCode) {
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
            if (result) {
                ApiSettingsController.getAccountInfo(true)
            }

            PageController.showBusyIndicator(false)
            if (result) {
                PageController.showNotificationMessage(qsTr("Config file saved"))
            }
        }
    }

    function revokeConfig(countryCode) {
        PageController.showBusyIndicator(true)
        let result = ApiConfigsController.revokeNativeConfig(countryCode)
        if (result) {
            ApiSettingsController.getAccountInfo(true)
        }
        PageController.showBusyIndicator(false)

        if (result) {
            PageController.showNotificationMessage(qsTr("The config has been revoked"))
        }
    }

    function showQuestion(isConfigIssue, countryCode, countryName) {
        var headerText = qsTr("Revoke the actual %1 configuration file?").arg(countryName)
        var descriptionText = qsTr("The previously created file will no longer be valid. It will not be possible to connect using it.")
        var yesButtonText = qsTr("Continue")
        var noButtonText = qsTr("Cancel")

        var yesButtonFunction = function() {
            if (isConfigIssue) {
                issueConfig(countryCode)
            } else {
                revokeConfig(countryCode)
            }
            moreOptionsDrawer.closeTriggered()
        }
        var noButtonFunction = function() {
        }

        showQuestionDrawer(headerText, descriptionText, yesButtonText, noButtonText, yesButtonFunction, noButtonFunction)
    }
}
