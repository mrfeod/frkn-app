#ifndef APIUTILS_H
#define APIUTILS_H

#include <QObject>

#include "apiDefs.h"

namespace apiUtils
{
    bool isServerFromApi(const QJsonObject &serverConfigObject);

    bool isSubscriptionExpired(const QString &subscriptionEndDate);

    apiDefs::ConfigType getConfigType(const QJsonObject &serverConfigObject);
    apiDefs::ConfigSource getConfigSource(const QJsonObject &serverConfigObject);
}

#endif // APIUTILS_H
