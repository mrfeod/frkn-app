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

    QtObject {
        id: windows

        readonly property string title: qsTr("Windows")
        readonly property string imageSource: "qrc:/images/controls/external-link.svg"
        readonly property var handler: function() {
            Qt.openUrlExternally(LanguageModel.getCurrentSiteUrl())
        }
    }

    QtObject {
        id: linux

        readonly property string title: qsTr("Windows")
        readonly property string imageSource: "qrc:/images/controls/external-link.svg"
        readonly property var handler: function() {
            Qt.openUrlExternally(LanguageModel.getCurrentSiteUrl())
        }
    }

    property list<QtObject> instructionsModel: [
        windows,
        linux
    ]

    ListViewType {
        id: listView

        anchors.fill: parent

        model: instructionsModel

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

                headerText: "Support"
                descriptionText: qsTr("Our technical support specialists are ready to help you at any time")
            }
        }

        delegate: ColumnLayout {
            width: listView.width

            LabelWithButtonType {
                id: telegramButton
                Layout.fillWidth: true
                Layout.topMargin: 6

                text: title
                leftImageSource: imageSource

                clickedFunction: handler
            }

            DividerType {}
        }
    }
}
