import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

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

    property list<QtObject> labelsModel: [
        statusObject,
        endDateObject,
        deviceCountObject
    ]

    QtObject {
        id: statusObject

        readonly property string title: qsTr("Subscription status")
        readonly property string contentKey: "subscriptionStatus"
        readonly property string objectImageSource: "qrc:/images/controls/map-pin.svg"
    }

    QtObject {
        id: endDateObject

        readonly property string title: qsTr("Valid until")
        readonly property string contentKey: "endDate"
        readonly property string objectImageSource: "qrc:/images/controls/history.svg"
    }

    QtObject {
        id: deviceCountObject

        readonly property string title: qsTr("Connected devices")
        readonly property string contentKey: "connectedDevices"
        readonly property string objectImageSource: "qrc:/images/controls/gauge.svg"
    }

    property var processedServer

    Connections {
        target: ServersModel

        function onProcessedServerChanged() {
            root.processedServer = proxyServersModel.get(0)
        }
    }

    SortFilterProxyModel {
        id: proxyServersModel
        objectName: "proxyServersModel"

        sourceModel: ServersModel
        filters: [
            ValueFilter {
                roleName: "isCurrentlyProcessed"
                value: true
            }
        ]

        Component.onCompleted: {
            root.processedServer = proxyServersModel.get(0)
        }
    }

    ListViewType {
        id: listView

        anchors.fill: parent

        model: labelsModel

        header: ColumnLayout {
            width: listView.width

            spacing: 4

            BackButtonType {
                id: backButton
                objectName: "backButton"

                Layout.topMargin: 20
            }

            HeaderType {
                id: headerContent
                objectName: "headerContent"

                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 10

                actionButtonImage: "qrc:/images/controls/edit-3.svg"

                headerText: root.processedServer.name
                descriptionText: ApiAccountInfoModel.data("serviceDescription")

                actionButtonFunction: function() {
                    serverNameEditDrawer.openTriggered()
                }
            }

            RenameServerDrawer {
                id: serverNameEditDrawer

                parent: root

                anchors.fill: parent
                expandedHeight: root.height * 0.35

                serverNameText: root.processedServer.name
            }
        }

        delegate: ColumnLayout {
            width: listView.width
            spacing: 0

            LabelWithImageType {
                Layout.fillWidth: true
                Layout.margins: 16

                imageSource: objectImageSource
                leftText: title
                rightText: ApiAccountInfoModel.data(contentKey)

                visible: rightText !== ""
            }
        }

        footer: ColumnLayout {
            width: listView.width
            spacing: 0

            LabelWithButtonType {
                id: vpnKey

                Layout.fillWidth: true
                Layout.topMargin: 32

                visible: false

                text: qsTr("Subscription key")
                rightImageSource: "qrc:/images/controls/chevron-right.svg"

                clickedFunction: function() {
                }
            }

            DividerType {
                visible: false
            }

            LabelWithButtonType {
                Layout.fillWidth: true
                Layout.topMargin: vpnKey.visible ? 0 : 32

                text: qsTr("Configuration files")

                descriptionText: qsTr("To connect a router or AmneziaWG application")
                rightImageSource: "qrc:/images/controls/chevron-right.svg"

                clickedFunction: function() {
                    ApiSettingsController.updateApiCountryModel()
                    PageController.goToPage(PageEnum.PageSettingsApiNativeConfigs)
                }
            }

            DividerType {}

            LabelWithButtonType {
                Layout.fillWidth: true

                text: qsTr("Support")
                rightImageSource: "qrc:/images/controls/chevron-right.svg"

                clickedFunction: function() {
                    PageController.goToPage(PageEnum.PageSettingsApiSupport)
                }
            }

            DividerType {}

            LabelWithButtonType {
                Layout.fillWidth: true

                text: qsTr("How to connect on another devicey")
                rightImageSource: "qrc:/images/controls/chevron-right.svg"

                clickedFunction: function() {
                    PageController.goToPage(PageEnum.PageSettingsApiInstructions)
                }
            }

            DividerType {}

            BasicButtonType {
                id: resetButton
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
                Layout.bottomMargin: 16
                Layout.leftMargin: 8
                implicitHeight: 32

                defaultColor: "transparent"
                hoveredColor: AmneziaStyle.color.translucentWhite
                pressedColor: AmneziaStyle.color.sheerWhite
                textColor: AmneziaStyle.color.vibrantRed

                text: qsTr("Reload API config")

                clickedFunc: function() {
                    var headerText = qsTr("Reload API config?")
                    var yesButtonText = qsTr("Continue")
                    var noButtonText = qsTr("Cancel")

                    var yesButtonFunction = function() {
                        if (ServersModel.isDefaultServerCurrentlyProcessed() && ConnectionController.isConnected) {
                            PageController.showNotificationMessage(qsTr("Cannot reload API config during active connection"))
                        } else {
                            PageController.showBusyIndicator(true)
                            InstallController.updateServiceFromApi(ServersModel.processedIndex, "", "", true)
                            PageController.showBusyIndicator(false)
                        }
                    }
                    var noButtonFunction = function() {
                        if (!GC.isMobile()) {
                            removeButton.forceActiveFocus()
                        }
                    }

                    showQuestionDrawer(headerText, "", yesButtonText, noButtonText, yesButtonFunction, noButtonFunction)
                }
            }

            BasicButtonType {
                id: removeButton
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 16
                Layout.leftMargin: 8
                implicitHeight: 32

                defaultColor: "transparent"
                hoveredColor: AmneziaStyle.color.translucentWhite
                pressedColor: AmneziaStyle.color.sheerWhite
                textColor: AmneziaStyle.color.vibrantRed

                text: qsTr("Remove from application")

                clickedFunc: function() {
                    var headerText = qsTr("Remove from application?")
                    var yesButtonText = qsTr("Continue")
                    var noButtonText = qsTr("Cancel")

                    var yesButtonFunction = function() {
                        if (ServersModel.isDefaultServerCurrentlyProcessed() && ConnectionController.isConnected) {
                            PageController.showNotificationMessage(qsTr("Cannot remove server during active connection"))
                        } else {
                            PageController.showBusyIndicator(true)
                            InstallController.removeProcessedServer()
                            PageController.showBusyIndicator(false)
                        }
                    }
                    var noButtonFunction = function() {
                        if (!GC.isMobile()) {
                            removeButton.forceActiveFocus()
                        }
                    }

                    showQuestionDrawer(headerText, "", yesButtonText, noButtonText, yesButtonFunction, noButtonFunction)
                }
            }
        }
    }
}
