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
        readonly property string link: qsTr("")
    }

    QtObject {
        id: macos

        readonly property string title: qsTr("macOS")
        readonly property string link: qsTr("")
    }

    QtObject {
        id: android

        readonly property string title: qsTr("Android")
        readonly property string link: qsTr("")
    }

    QtObject {
        id: androidTv

        readonly property string title: qsTr("AndroidTV")
        readonly property string link: qsTr("")
    }

    QtObject {
        id: ios

        readonly property string title: qsTr("iOS")
        readonly property string link: qsTr("")
    }

    QtObject {
        id: linux

        readonly property string title: qsTr("Linux")
        readonly property string link: qsTr("")
    }

    QtObject {
        id: routers

        readonly property string title: qsTr("Routers")
        readonly property string link: qsTr("")
    }

    property list<QtObject> instructionsModel: [
        windows,
        macos,
        android,
        androidTv,
        ios,
        linux,
        routers
    ]

    ListViewType {
        id: listView

        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 24

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

                headerText: qsTr("How to connect on another device")
                descriptionText: qsTr("Instructions on the Amnezia website")
            }
        }

        delegate: ColumnLayout {
            width: listView.width

            LabelWithButtonType {
                id: telegramButton
                Layout.fillWidth: true
                Layout.topMargin: 6

                text: title
                rightImageSource: "qrc:/images/controls/external-link.svg"

                clickedFunction: function() {
                    Qt.openUrlExternally(link)
                }
            }

            DividerType {}
        }
    }
}
