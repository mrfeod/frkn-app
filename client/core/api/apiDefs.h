#ifndef APIDEFS_H
#define APIDEFS_H

#include <QString>

namespace apiDefs
{
    enum ConfigType {
        AmneziaFreeV2 = 1,
        AmneziaFreeV3,
        AmneziaPremiumV1,
        AmneziaPremiumV2,
        SelfHosted
    };

    enum ConfigSource {
        Telegram = 1,
        AmneziaGateway
    };

    namespace key
    {
        constexpr QLatin1String configVersion("config_version");

        constexpr QLatin1String apiConfig("api_config");
        constexpr QLatin1String stackType("stack_type");

        constexpr QLatin1String vpnKey("vpn_key");
    }

    const int requestTimeoutMsecs = 12 * 1000; // 12 secs
}

#endif // APIDEFS_H
