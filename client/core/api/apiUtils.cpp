#include "apiUtils.h"

#include <QDateTime>
#include <QJsonObject>

bool apiUtils::isSubscriptionExpired(const QString &subscriptionEndDate)
{
    QDateTime now = QDateTime::currentDateTime();
    QDateTime endDate = QDateTime::fromString(subscriptionEndDate, Qt::ISODateWithMs);
    return endDate < now;
}

bool apiUtils::isServerFromApi(const QJsonObject &serverConfigObject)
{
    auto configVersion = serverConfigObject.value(apiDefs::key::configVersion).toInt();
    switch (configVersion) {
    case apiDefs::ConfigSource::Telegram: return true;
    case apiDefs::ConfigSource::AmneziaGateway: return true;
    default: return false;
    }
}

apiDefs::ConfigType apiUtils::getConfigType(const QJsonObject &serverConfigObject)
{
    auto configVersion = serverConfigObject.value(apiDefs::key::configVersion).toInt();
    switch (configVersion) {
    case apiDefs::ConfigSource::Telegram: {
    };
    case apiDefs::ConfigSource::AmneziaGateway: {
        constexpr QLatin1String premium("prem");
        constexpr QLatin1String free("free");

        auto apiConfigObject = serverConfigObject.value(apiDefs::key::apiConfig).toObject();
        auto stackType = apiConfigObject.value(apiDefs::key::stackType).toString();

        if (stackType == premium) {
            return apiDefs::ConfigType::AmneziaPremiumV2;
        } else if (stackType == free) {
            return apiDefs::ConfigType::AmneziaFreeV3;
        }
    }
    default: {
        return apiDefs::ConfigType::SelfHosted;
    }
    };
}
