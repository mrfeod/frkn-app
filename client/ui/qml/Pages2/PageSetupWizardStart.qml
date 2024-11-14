import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import PageEnum 1.0
import Style 1.0

import Bip39Helper 1.0

import "./"
import "../Controls2"
import "../Config"
import "../Controls2/TextTypes"
import "../Components"

PageType {
    id: root

    defaultActiveFocusItem: focusItem

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: 0

        Item {
            id: focusItem
            KeyNavigation.tab: textKey
        }

        Header2Type {
            Layout.fillWidth: true
            Layout.topMargin: 24
            Layout.bottomMargin: 10
            Layout.rightMargin: 16
            Layout.leftMargin: 16

            headerText: qsTr("Log in FRKN")
        }

        Image {
            id: image
            source: "qrc:/images/amneziaBigLogo.png"

            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth: 180
            Layout.preferredHeight: 144
            Layout.bottomMargin: 10
        }

        LabelTextType {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 10

            text: qsTr("FRKN provides complete anonymity without collecting personal data. Upon registration, you will be provided with a unique 12 words mnemophrase.")
        }

        LabelTextType {
            id: warningText
            Layout.fillWidth: true
            Layout.bottomMargin: 10
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            visible: false

            text: qsTr("● Record and securely save your mnemophrase\n\n● Do not share your mnemophrase with anyone\n\n● In case of loss, recovery is impossible")
        }

        TextFieldWithHeaderType {
            id: textKey

            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 10

            property bool hasValidPhrase: Bip39Helper.validatePhrase(textField.text)

            headerText: qsTr("Your 12 words mnemophrase")
            buttonText: qsTr("Insert")
            textFieldPlaceholderText: qsTr("frog roof kitchen nature ...")

            borderColor: textField.text === "" ? AmneziaStyle.color.slateGray : (hasValidPhrase ? AmneziaStyle.color.goldenApricot : AmneziaStyle.color.vibrantRed)
            borderFocusedColor: textField.text === "" ? AmneziaStyle.color.paleGray : (hasValidPhrase ? AmneziaStyle.color.goldenApricot : AmneziaStyle.color.vibrantRed)

            clickedFunc: function() {
                textField.text = ""
                textField.paste()
            }

            KeyNavigation.tab: lastItemTabClicked(focusItem)
        }

        Item
        {
            Layout.fillHeight: true
        }

        BasicButtonType {
            id: copyButton
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 10
            visible: false

            property bool phraseCopied: false

            text: qsTr("Copy mnemonic phrase")

            clickedFunc: function() {
                GC.copyToClipBoard(textKey.textFieldText)
                PageController.showNotificationMessage(qsTr("Copied"))
                phraseCopied = true
            }

            Keys.onTabPressed: lastItemTabClicked(focusItem)
        }

        BasicButtonType {
            id: registerButton
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 10

            text: qsTr("Register")

            visible: !textKey.hasValidPhrase

            clickedFunc: function() {
                textKey.buttonText = ""
                textKey.textFieldText = Bip39Helper.generatePhrase()
                textKey.textFieldEditable = false

                visible = false
                copyButton.visible = true
                warningText.visible = true
            }

            Keys.onTabPressed: lastItemTabClicked(focusItem)
        }

        BasicButtonType {
            id: loginButton
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 48

            enabled: textKey.hasValidPhrase && (!copyButton.visible || copyButton.phraseCopied)

            text: qsTr("Log in")

            clickedFunc: function() {
                // TODO Request configs
                // Use mock server to receive configs
                // See how PageSetupWizardConfigSource.qml manages it
                console.log("User hash: " + Bip39Helper.generateSha3_512(textKey.textFieldText))
                // vmess://eyJhZGQiOiAiMTk0LjU0LjE1Ni43OSIsICJhaWQiOiAiMCIsICJob3N0IjogImdvb2dsZS5jb20iLCAiaWQiOiAiMTkzM2RkN2ItN2UwZi00NDcyLTg0ODAtNWI1ZTE1YjVjYzQzIiwgIm5ldCI6ICJ0Y3AiLCAicGF0aCI6ICIvIiwgInBvcnQiOiA4MDgxLCAicHMiOiAiXHVkODNjXHVkZGYzXHVkODNjXHVkZGYxIE5MLTEgW0ZSS05dIFZNZXNzIiwgInNjeSI6ICJhdXRvIiwgInRscyI6ICJub25lIiwgInR5cGUiOiAiaHR0cCIsICJ2IjogIjIifQ==
                // PageController.goToPage(PageEnum.PageSetupWizardConfigSource)
                let configData = "vmess://eyJhZGQiOiAiMTk0LjU0LjE1Ni43OSIsICJhaWQiOiAiMCIsICJob3N0IjogImdvb2dsZS5jb20iLCAiaWQiOiAiMTkzM2RkN2ItN2UwZi00NDcyLTg0ODAtNWI1ZTE1YjVjYzQzIiwgIm5ldCI6ICJ0Y3AiLCAicGF0aCI6ICIvIiwgInBvcnQiOiA4MDgxLCAicHMiOiAiXHVkODNjXHVkZGYzXHVkODNjXHVkZGYxIE5MLTEgW0ZSS05dIFZNZXNzIiwgInNjeSI6ICJhdXRvIiwgInRscyI6ICJub25lIiwgInR5cGUiOiAiaHR0cCIsICJ2IjogIjIifQ=="
                ImportController.extractConfigFromData(configData)
                ImportController.importConfig()
            }

            Keys.onTabPressed: lastItemTabClicked(focusItem)
        }
    }

    Connections {
        target: ImportController

        function onImportErrorOccurred(errorMessage, goToPageHome) {
            if (goToPageHome) {
                PageController.goToStartPage()
            } else {
                PageController.closePage()
            }
        }

        function onImportFinished() {
            if (!ConnectionController.isConnected) {
                ServersModel.setDefaultServerIndex(ServersModel.getServersCount() - 1);
                ServersModel.processedIndex = ServersModel.defaultIndex
            }

            PageController.goToPageHome()
        }
    }
}
