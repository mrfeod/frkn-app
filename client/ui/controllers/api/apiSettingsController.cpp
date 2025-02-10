#include "apiSettingsController.h"

#include "core/api/apiUtils.h"
#include "core/controllers/gatewayController.h"

namespace
{
    namespace configKey
    {
        constexpr char userCountryCode[] = "user_country_code";
        constexpr char serverCountryCode[] = "server_country_code";
        constexpr char serviceType[] = "service_type";
        constexpr char serviceInfo[] = "service_info";

        constexpr char apiConfig[] = "api_config";
        constexpr char authData[] = "auth_data";
    }

    const int requestTimeoutMsecs = 12 * 1000; // 12 secs
}

ApiSettingsController::ApiSettingsController(const QSharedPointer<ServersModel> &serversModel,
                                             const QSharedPointer<ApiAccountInfoModel> &apiAccountInfoModel,
                                             const QSharedPointer<ApiCountryModel> &apiCountryModel,
                                             const std::shared_ptr<Settings> &settings, QObject *parent)
    : QObject(parent),
      m_serversModel(serversModel),
      m_apiAccountInfoModel(apiAccountInfoModel),
      m_apiCountryModel(apiCountryModel),
      m_settings(settings)
{
}

ApiSettingsController::~ApiSettingsController()
{
}

bool ApiSettingsController::getAccountInfo()
{
    GatewayController gatewayController(m_settings->getGatewayEndpoint(), m_settings->isDevGatewayEnv(), requestTimeoutMsecs);

    auto processedIndex = m_serversModel->getProcessedServerIndex();
    auto serverConfig = m_serversModel->getServerConfig(processedIndex);
    auto apiConfig = serverConfig.value(configKey::apiConfig).toObject();
    auto authData = serverConfig.value(configKey::authData).toObject();

    QJsonObject apiPayload;
    apiPayload[configKey::userCountryCode] = apiConfig.value(configKey::userCountryCode).toString();
    apiPayload[configKey::serviceType] = apiConfig.value(configKey::serviceType).toString();
    apiPayload[configKey::authData] = authData;

    QByteArray responseBody;

    if (apiUtils::getConfigType(serverConfig) == apiDefs::ConfigType::AmneziaPremiumV2) {
        ErrorCode errorCode = gatewayController.post(QString("%1v1/account_info"), apiPayload, responseBody);
        if (errorCode != ErrorCode::NoError) {
            emit errorOccurred(errorCode);
            return false;
        }
    }

    QJsonObject accountInfo = QJsonDocument::fromJson(responseBody).object();
    m_apiAccountInfoModel->updateModel(accountInfo, serverConfig);

    return true;
}

void ApiSettingsController::updateApiCountryModel()
{
    m_apiCountryModel->updateModel(m_apiAccountInfoModel->getAvailableCountries(), "");
}
