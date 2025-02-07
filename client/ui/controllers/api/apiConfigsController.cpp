#include "ApiConfigsController.h"

#include "configurators/wireguard_configurator.h"
#include "core/api/apiDefs.h"
#include "core/controllers/gatewayController.h"
#include "version.h"
#include "ui/controllers/systemController.h"

namespace
{
    namespace configKey
    {
        constexpr char cloak[] = "cloak";
        constexpr char awg[] = "awg";

        constexpr char apiEdnpoint[] = "api_endpoint";
        constexpr char accessToken[] = "api_key";
        constexpr char certificate[] = "certificate";
        constexpr char publicKey[] = "public_key";

        constexpr char uuid[] = "installation_uuid";
        constexpr char osVersion[] = "os_version";
        constexpr char appVersion[] = "app_version";

        constexpr char userCountryCode[] = "user_country_code";
        constexpr char serverCountryCode[] = "server_country_code";
        constexpr char serviceType[] = "service_type";
        constexpr char serviceInfo[] = "service_info";
        constexpr char serviceProtocol[] = "service_protocol";

        constexpr char aesKey[] = "aes_key";
        constexpr char aesIv[] = "aes_iv";
        constexpr char aesSalt[] = "aes_salt";

        constexpr char apiPayload[] = "api_payload";
        constexpr char keyPayload[] = "key_payload";

        constexpr char apiConfig[] = "api_config";
        constexpr char authData[] = "auth_data";

        constexpr char config[] = "config";
    }
}

ApiConfigsController::ApiConfigsController(const QSharedPointer<ServersModel> &serversModel, const std::shared_ptr<Settings> &settings,
                                         QObject *parent)
    : QObject(parent), m_serversModel(serversModel), m_settings(settings)
{
}

void ApiConfigsController::exportNativeConfig(const QString &serverCountryCode, const QString &fileName)
{
    GatewayController gatewayController(m_settings->getGatewayEndpoint(), m_settings->isDevGatewayEnv(), apiDefs::requestTimeoutMsecs);

    auto serverConfigObject = m_serversModel->getServerConfig(m_serversModel->getProcessedServerIndex());
    auto apiConfigObject = serverConfigObject.value(configKey::apiConfig).toObject();

    QString protocol = apiConfigObject.value(configKey::serviceProtocol).toString();
    ApiPayloadData apiPayloadData = generateApiPayloadData(protocol);

    QJsonObject apiPayload = fillApiPayload(protocol, apiPayloadData);
    apiPayload[configKey::userCountryCode] = apiConfigObject.value(configKey::userCountryCode);
    apiPayload[configKey::serverCountryCode] = apiConfigObject.value(configKey::serverCountryCode);
    apiPayload[configKey::serviceType] = apiConfigObject.value(configKey::serviceType);
    apiPayload[configKey::authData] = serverConfigObject.value(configKey::authData);
    apiPayload[configKey::uuid] = m_settings->getInstallationUuid(true);

    QByteArray responseBody;
    ErrorCode errorCode = gatewayController.post(QString("%1v1/native_config"), apiPayload, responseBody);
    // // if (errorCode != ErrorCode::NoError) {

    // // }

    QJsonObject jsonConfig = QJsonDocument::fromJson(responseBody).object();
    QString nativeConfig = jsonConfig.value(configKey::config).toString();

    SystemController::saveFile(fileName, nativeConfig);
}

ApiConfigsController::ApiPayloadData ApiConfigsController::generateApiPayloadData(const QString &protocol)
{
    ApiConfigsController::ApiPayloadData apiPayload;
    if (protocol == configKey::cloak) {
        apiPayload.certRequest = OpenVpnConfigurator::createCertRequest();
    } else if (protocol == configKey::awg) {
        auto connData = WireguardConfigurator::genClientKeys();
        apiPayload.wireGuardClientPubKey = connData.clientPubKey;
        apiPayload.wireGuardClientPrivKey = connData.clientPrivKey;
    }
    return apiPayload;
}

QJsonObject ApiConfigsController::fillApiPayload(const QString &protocol, const ApiPayloadData &apiPayloadData)
{
    QJsonObject obj;
    if (protocol == configKey::cloak) {
        obj[configKey::certificate] = apiPayloadData.certRequest.request;
    } else if (protocol == configKey::awg) {
        obj[configKey::publicKey] = apiPayloadData.wireGuardClientPubKey;
    }

    obj[configKey::osVersion] = QSysInfo::productType();
    obj[configKey::appVersion] = QString(APP_VERSION);

    return obj;
}
