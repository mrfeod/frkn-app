import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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

    ColumnLayout {
        id: backButtonLayout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.topMargin: 20

        BackButtonType {
            id: backButton
        }


        HeaderType {
            id: header

            Layout.fillWidth: true
            Layout.rightMargin: 16
            Layout.leftMargin: 16

            headerText: "Support"
            descriptionText: qsTr("Our technical support specialists are ready to help you at any time")
        }

        LabelWithButtonType {
            Layout.fillWidth: true

            text: qsTr("Telegram")
            descriptionText: qsTr("@amnezia_premium_support_bot")
            rightImageSource: "qrc:/images/controls/external-link.svg"

            clickedFunction: function() {
                Qt.openUrlExternally(qsTr("https://t.me/amnezia_premium_support_bot"))
            }
        }

        DividerType {}

        LabelWithButtonType {
            Layout.fillWidth: true

            text: qsTr("Mail")
            descriptionText: qsTr("support@amnezia.org")
            rightImageSource: "qrc:/images/controls/external-link.svg"

            clickedFunction: function() {
                Qt.openUrlExternally(qsTr("mailto:support@amnezia.org"))
            }
        }

        DividerType {}

        LabelWithButtonType {
            Layout.fillWidth: true

            text: qsTr("Site")
            descriptionText: qsTr("amnezia.org")
            rightImageSource: "qrc:/images/controls/external-link.svg"

            clickedFunction: function() {
                Qt.openUrlExternally(LanguageModel.getCurrentSiteUrl())
            }
        }

        DividerType {}

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
    }
}
