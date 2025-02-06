#ifndef APIUTILS_H
#define APIUTILS_H

#include <QObject>

namespace ApiUtils
{
    bool isSubscriptionExpired(const QString &subscriptionEndDate);
}

#endif // APIUTILS_H
