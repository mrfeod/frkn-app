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
        regionObject,
        priceObject,
        endDateObject,
        speedObject
    ]

    QtObject {
        id: regionObject

        readonly property string title: qsTr("For the region")
        readonly property string contentKey: "region"
        readonly property string objectImageSource: "qrc:/images/controls/map-pin.svg"
    }

    QtObject {
        id: priceObject

        readonly property string title: qsTr("Price")
        readonly property string contentKey: "price"
        readonly property string objectImageSource: "qrc:/images/controls/tag.svg"
    }

    QtObject {
        id: endDateObject

        readonly property string title: qsTr("Valid until")
        readonly property string contentKey: "endDate"
        readonly property string objectImageSource: "qrc:/images/controls/history.svg"
    }

    QtObject {
        id: speedObject

        readonly property string title: qsTr("Speed")
        readonly property string contentKey: "speed"
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

    ListView {
        id: listView

        property bool isFocusable: true

        anchors.fill: parent

        Keys.onTabPressed: {
            FocusController.nextKeyTabItem()
        }

        Keys.onBacktabPressed: {
            FocusController.previousKeyTabItem()
        }

        Keys.onUpPressed: {
            FocusController.nextKeyUpItem()
        }

        Keys.onDownPressed: {
            FocusController.nextKeyDownItem()
        }

        Keys.onLeftPressed: {
            FocusController.nextKeyLeftItem()
        }

        Keys.onRightPressed: {
            FocusController.nextKeyRightItem()
        }

        ScrollBar.vertical: ScrollBarType {}

        clip: true
        reuseItems: true
        snapMode: ListView.SnapToItem

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
                descriptionText: ApiServicesModel.getSelectedServiceData("serviceDescription")

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
                rightText: ApiServicesModel.getSelectedServiceData(contentKey)

                visible: rightText !== ""
            }
        }

        footer: ColumnLayout {
            width: listView.width
            spacing: 0

            ParagraphTextType {
                Layout.fillWidth: true
                Layout.rightMargin: 16
                Layout.leftMargin: 16

                onLinkActivated: function(link) {
                    Qt.openUrlExternally(link)
                }
                textFormat: Text.RichText
                text: {
                    var text = ApiServicesModel.getSelectedServiceData("features")
                    if (text === undefined) {
                        return ""
                    }
                    return text.replace("%1", LanguageModel.getCurrentSiteUrl())
                }

                visible: text !== ""

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            LabelWithButtonType {
                id: supportUuid
                Layout.fillWidth: true

                text: qsTr("Support tag")
                descriptionText: SettingsController.getInstallationUuid()

                descriptionOnTop: true

                rightImageSource: "qrc:/images/controls/copy.svg"
                rightImageColor: AmneziaStyle.color.paleGray

                clickedFunction: function() {
                    GC.copyToClipBoard(descriptionText)
                    PageController.showNotificationMessage(qsTr("Copied"))
                    if (!GC.isMobile()) {
                        this.rightButton.forceActiveFocus()
                    }
                }
            }

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
