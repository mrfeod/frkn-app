#include "apiController.h"

#include <QEventLoop>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QtConcurrent>

#include "amnezia_application.h"
#include "configurators/wireguard_configurator.h"
#include "core/api/apiDefs.h"
#include "gatewayController.h"
#include "version.h"

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
        constexpr char protocol[] = "protocol";

        constexpr char uuid[] = "installation_uuid";
        constexpr char osVersion[] = "os_version";
        constexpr char appVersion[] = "app_version";

        constexpr char userCountryCode[] = "user_country_code";
        constexpr char serverCountryCode[] = "server_country_code";
        constexpr char serviceType[] = "service_type";
        constexpr char serviceInfo[] = "service_info";

        constexpr char aesKey[] = "aes_key";
        constexpr char aesIv[] = "aes_iv";
        constexpr char aesSalt[] = "aes_salt";

        constexpr char apiPayload[] = "api_payload";
        constexpr char keyPayload[] = "key_payload";

        constexpr char apiConfig[] = "api_config";
        constexpr char authData[] = "auth_data";
    }

    const int requestTimeoutMsecs = 12 * 1000; // 12 secs
}

ApiController::ApiController(const QString &gatewayEndpoint, bool isDevEnvironment, QObject *parent)
    : QObject(parent), m_gatewayEndpoint(gatewayEndpoint), m_isDevEnvironment(isDevEnvironment)
{
}

void ApiController::fillServerConfig(const QString &protocol, const ApiController::ApiPayloadData &apiPayloadData,
                                     const QByteArray &apiResponseBody, QJsonObject &serverConfig)
{
    QString data = QJsonDocument::fromJson(apiResponseBody).object().value(config_key::config).toString();

    data.replace("vpn://", "");
    QByteArray ba = QByteArray::fromBase64(data.toUtf8(), QByteArray::Base64UrlEncoding | QByteArray::OmitTrailingEquals);

    if (ba.isEmpty()) {
        emit errorOccurred(ErrorCode::ApiConfigEmptyError);
        return;
    }

    QByteArray ba_uncompressed = qUncompress(ba);
    if (!ba_uncompressed.isEmpty()) {
        ba = ba_uncompressed;
    }

    QString configStr = ba;
    if (protocol == configKey::cloak) {
        configStr.replace("<key>", "<key>\n");
        configStr.replace("$OPENVPN_PRIV_KEY", apiPayloadData.certRequest.privKey);
    } else if (protocol == configKey::awg) {
        configStr.replace("$WIREGUARD_CLIENT_PRIVATE_KEY", apiPayloadData.wireGuardClientPrivKey);
        auto newServerConfig = QJsonDocument::fromJson(configStr.toUtf8()).object();
        auto containers = newServerConfig.value(config_key::containers).toArray();
        if (containers.isEmpty()) {
            return; // todo process error
        }
        auto container = containers.at(0).toObject();
        QString containerName = ContainerProps::containerTypeToString(DockerContainer::Awg);
        auto containerConfig = container.value(containerName).toObject();
        auto protocolConfig = QJsonDocument::fromJson(containerConfig.value(config_key::last_config).toString().toUtf8()).object();
        containerConfig[config_key::junkPacketCount] = protocolConfig.value(config_key::junkPacketCount);
        containerConfig[config_key::junkPacketMinSize] = protocolConfig.value(config_key::junkPacketMinSize);
        containerConfig[config_key::junkPacketMaxSize] = protocolConfig.value(config_key::junkPacketMaxSize);
        containerConfig[config_key::initPacketJunkSize] = protocolConfig.value(config_key::initPacketJunkSize);
        containerConfig[config_key::responsePacketJunkSize] = protocolConfig.value(config_key::responsePacketJunkSize);
        containerConfig[config_key::initPacketMagicHeader] = protocolConfig.value(config_key::initPacketMagicHeader);
        containerConfig[config_key::responsePacketMagicHeader] = protocolConfig.value(config_key::responsePacketMagicHeader);
        containerConfig[config_key::underloadPacketMagicHeader] = protocolConfig.value(config_key::underloadPacketMagicHeader);
        containerConfig[config_key::transportPacketMagicHeader] = protocolConfig.value(config_key::transportPacketMagicHeader);
        container[containerName] = containerConfig;
        containers.replace(0, container);
        newServerConfig[config_key::containers] = containers;
        configStr = QString(QJsonDocument(newServerConfig).toJson());
    }

    QJsonObject newServerConfig = QJsonDocument::fromJson(configStr.toUtf8()).object();
    serverConfig[config_key::dns1] = newServerConfig.value(config_key::dns1);
    serverConfig[config_key::dns2] = newServerConfig.value(config_key::dns2);
    serverConfig[config_key::containers] = newServerConfig.value(config_key::containers);
    serverConfig[config_key::hostName] = newServerConfig.value(config_key::hostName);

    if (newServerConfig.value(config_key::configVersion).toInt() == apiDefs::ConfigSource::AmneziaGateway) {
        serverConfig[config_key::configVersion] = newServerConfig.value(config_key::configVersion);
        serverConfig[config_key::description] = newServerConfig.value(config_key::description);
        serverConfig[config_key::name] = newServerConfig.value(config_key::name);
    }

    auto defaultContainer = newServerConfig.value(config_key::defaultContainer).toString();
    serverConfig[config_key::defaultContainer] = defaultContainer;

    QVariantMap map = serverConfig.value(configKey::apiConfig).toObject().toVariantMap();
    map.insert(newServerConfig.value(configKey::apiConfig).toObject().toVariantMap());
    auto apiConfig = QJsonObject::fromVariantMap(map);

    if (newServerConfig.value(config_key::configVersion).toInt() == apiDefs::ConfigSource::AmneziaGateway) {
        apiConfig.insert(configKey::serviceInfo, QJsonDocument::fromJson(apiResponseBody).object().value(configKey::serviceInfo).toObject());
    }

    serverConfig[configKey::apiConfig] = apiConfig;

    return;
}

ApiController::ApiPayloadData ApiController::generateApiPayloadData(const QString &protocol)
{
    ApiController::ApiPayloadData apiPayload;
    if (protocol == configKey::cloak) {
        apiPayload.certRequest = OpenVpnConfigurator::createCertRequest();
    } else if (protocol == configKey::awg) {
        auto connData = WireguardConfigurator::genClientKeys();
        apiPayload.wireGuardClientPubKey = connData.clientPubKey;
        apiPayload.wireGuardClientPrivKey = connData.clientPrivKey;
    }
    return apiPayload;
}

QJsonObject ApiController::fillApiPayload(const QString &protocol, const ApiController::ApiPayloadData &apiPayloadData)
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

void ApiController::updateServerConfigFromApi(const QString &installationUuid, const int serverIndex, QJsonObject serverConfig)
{
#ifdef Q_OS_IOS
    IosController::Instance()->requestInetAccess();
    QThread::msleep(10);
#endif

    if (serverConfig.value(config_key::configVersion).toInt()) {
        QNetworkRequest request;
        request.setTransferTimeout(requestTimeoutMsecs);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        request.setRawHeader("Authorization", "Api-Key " + serverConfig.value(configKey::accessToken).toString().toUtf8());
        QString endpoint = serverConfig.value(configKey::apiEdnpoint).toString();
        request.setUrl(endpoint);

        QString protocol = serverConfig.value(configKey::protocol).toString();

        ApiPayloadData apiPayloadData = generateApiPayloadData(protocol);

        QJsonObject apiPayload = fillApiPayload(protocol, apiPayloadData);
        apiPayload[configKey::uuid] = installationUuid;

        QByteArray requestBody = QJsonDocument(apiPayload).toJson();

        QNetworkReply *reply = amnApp->manager()->post(request, requestBody);

        QObject::connect(reply, &QNetworkReply::finished, [this, reply, protocol, apiPayloadData, serverIndex, serverConfig]() mutable {
            if (reply->error() == QNetworkReply::NoError) {
                auto apiResponseBody = reply->readAll();
                fillServerConfig(protocol, apiPayloadData, apiResponseBody, serverConfig);
                emit finished(serverConfig, serverIndex);
            } else {
                if (reply->error() == QNetworkReply::NetworkError::OperationCanceledError
                    || reply->error() == QNetworkReply::NetworkError::TimeoutError) {
                    emit errorOccurred(ErrorCode::ApiConfigTimeoutError);
                } else {
                    QString err = reply->errorString();
                    qDebug() << QString::fromUtf8(reply->readAll());
                    qDebug() << reply->error();
                    qDebug() << err;
                    qDebug() << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                    emit errorOccurred(ErrorCode::ApiConfigDownloadError);
                }
            }

            reply->deleteLater();
        });

        QObject::connect(reply, &QNetworkReply::errorOccurred,
                         [this, reply](QNetworkReply::NetworkError error) { qDebug() << reply->errorString() << error; });
        connect(reply, &QNetworkReply::sslErrors, [this, reply](const QList<QSslError> &errors) {
            qDebug().noquote() << errors;
            emit errorOccurred(ErrorCode::ApiConfigSslError);
        });
    }
}

ErrorCode ApiController::getAccountInfo(const QString &userCountryCode, const QString &serviceType, const QJsonObject &authData,
                                        QByteArray &responseBody)
{
    GatewayController gatewayController(m_gatewayEndpoint, m_isDevEnvironment, requestTimeoutMsecs);

    QJsonObject apiPayload;
    apiPayload[configKey::userCountryCode] = userCountryCode;
    apiPayload[configKey::serviceType] = serviceType;
    apiPayload[configKey::authData] = authData;

    ErrorCode errorCode = gatewayController.post(QString("%1v1/account_info"), apiPayload, responseBody);

    return errorCode;
}

ErrorCode ApiController::getServicesList(QByteArray &responseBody)
{
    GatewayController gatewayController(m_gatewayEndpoint, m_isDevEnvironment, requestTimeoutMsecs);

    QJsonObject apiPayload;
    apiPayload[configKey::osVersion] = QSysInfo::productType();

    ErrorCode errorCode = gatewayController.post(QString("%1v1/services"), apiPayload, responseBody);
    if (errorCode == ErrorCode::NoError) {
        if (!responseBody.contains("services")) {
            return ErrorCode::ApiServicesMissingError;
        }
    }

    return errorCode;
}

ErrorCode ApiController::getConfigForService(const QString &installationUuid, const QString &userCountryCode, const QString &serviceType,
                                             const QString &protocol, const QString &serverCountryCode, const QJsonObject &authData,
                                             QJsonObject &serverConfig)
{
    GatewayController gatewayController(m_gatewayEndpoint, m_isDevEnvironment, requestTimeoutMsecs);

    ApiPayloadData apiPayloadData = generateApiPayloadData(protocol);

    QJsonObject apiPayload = fillApiPayload(protocol, apiPayloadData);
    apiPayload[configKey::userCountryCode] = userCountryCode;
    if (!serverCountryCode.isEmpty()) {
        apiPayload[configKey::serverCountryCode] = serverCountryCode;
    }
    apiPayload[configKey::serviceType] = serviceType;
    apiPayload[configKey::uuid] = installationUuid;
    if (!authData.isEmpty()) {
        apiPayload[configKey::authData] = authData;
    }

    QByteArray responseBody;
    ErrorCode errorCode = gatewayController.post(QString("%1v1/config"), apiPayload, responseBody);

    if (errorCode == ErrorCode::NoError) {
        fillServerConfig(protocol, apiPayloadData, responseBody, serverConfig);
    }

    return errorCode;
}


