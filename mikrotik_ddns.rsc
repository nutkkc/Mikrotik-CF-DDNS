# 2025-11-23 23:32:15 by RouterOS 7.18.2
# software id = HHJH-UFWL
#
/system script
add dont-require-permissions=no name=cloudflare-ddns owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \_==========================\
    \n# Cloudflare DDNS for MikroTik\
    \n# - \E0\B9\83\E0\B8\8A\E0\B9\89 :resolve myip.opendns.com \E0\B8\AB\E0\
    \B8\B2\E0\B8\84\E0\B9\88\E0\B8\B2 Public IP\
    \n# - \E0\B9\83\E0\B8\8A\E0\B9\89 global cfLastIP \E0\B9\80\E0\B8\81\E0\B9\
    \87\E0\B8\9A IP \E0\B8\A5\E0\B9\88\E0\B8\B2\E0\B8\AA\E0\B8\B8\E0\B8\94\
    \n# - \E0\B8\96\E0\B9\89\E0\B8\B2 IP \E0\B9\80\E0\B8\94\E0\B8\B4\E0\B8\A1 \
    = IP \E0\B9\83\E0\B8\AB\E0\B8\A1\E0\B9\88 \E2\86\92 \E0\B9\84\E0\B8\A1\E0\
    \B9\88\E0\B8\95\E0\B9\89\E0\B8\AD\E0\B8\87\E0\B9\80\E0\B8\A3\E0\B8\B5\E0\
    \B8\A2\E0\B8\81 Cloudflare\
    \n# ==========================\
    \n\
    \n:local cfToken \"cfToken\";\
    \n:local zoneID \"zoneID\";\
    \n:local ddnsName \"ddnsName.ddnsName.xyz\";\
    \n\
    \n\
    \n:local envid [/system script environment find where name=\"cfLastIP\"]\
    \n:global cfLastIP;\
    \n\
    \n:if (\$envid = \"\") do={\
    \n    :set cfLastIP \"\"\
    \n}\
    \n\
    \n# ---- \E0\B9\80\E0\B8\95\E0\B8\A3\E0\B8\B5\E0\B8\A2\E0\B8\A1 global \E0\
    \B8\AA\E0\B8\B3\E0\B8\AB\E0\B8\A3\E0\B8\B1\E0\B8\9A\E0\B9\80\E0\B8\81\E0\
    \B9\87\E0\B8\9A IP \E0\B8\A5\E0\B9\88\E0\B8\B2\E0\B8\AA\E0\B8\B8\E0\B8\94 \
    (\E0\B8\84\E0\B8\A3\E0\B8\B1\E0\B9\89\E0\B8\87\E0\B9\81\E0\B8\A3\E0\B8\81\
    \E0\B9\83\E0\B8\AB\E0\B9\89\E0\B8\AA\E0\B8\A3\E0\B9\89\E0\B8\B2\E0\B8\87\
    \E0\B9\80\E0\B8\9B\E0\B9\87\E0\B8\99\E0\B8\A7\E0\B9\88\E0\B8\B2\E0\B8\87) \
    ----\
    \n#:if ([:len [/system script environment find name=\"cfLastIP\"]] = 0) do\
    ={\
    \n#    :global cfLastIP \"\";\
    \n#}\
    \n\
    \n\
    \n# 1) \E0\B8\94\E0\B8\B6\E0\B8\87 IP \E0\B8\9B\E0\B8\B1\E0\B8\88\E0\B8\88\
    \E0\B8\B8\E0\B8\9A\E0\B8\B1\E0\B8\99\E0\B8\88\E0\B8\B2\E0\B8\81 OpenDNS (P\
    ublic IP)\
    \n:local currentIP [:resolve myip.opendns.com server=208.67.222.222];\
    \n\
    \n:if ([:len \"\$currentIP\"] = 0) do={\
    \n    :log warning \"CF-DDNS: cannot resolve public IP from OpenDNS\";\
    \n    :return;\
    \n}\
    \n\
    \n# 2) \E0\B8\96\E0\B9\89\E0\B8\B2\E0\B8\A1\E0\B8\B5\E0\B8\84\E0\B9\88\E0\
    \B8\B2\E0\B9\80\E0\B8\81\E0\B9\88\E0\B8\B2\E0\B8\AD\E0\B8\A2\E0\B8\B9\E0\
    \B9\88\E0\B9\81\E0\B8\A5\E0\B9\89\E0\B8\A7 \E0\B9\81\E0\B8\A5\E0\B8\B0 IP \
    \E0\B9\80\E0\B8\94\E0\B8\B4\E0\B8\A1 = IP \E0\B9\83\E0\B8\AB\E0\B8\A1\E0\
    \B9\88 \E2\86\92 \E0\B8\82\E0\B9\89\E0\B8\B2\E0\B8\A1 \E0\B9\84\E0\B8\A1\
    \E0\B9\88\E0\B8\95\E0\B9\89\E0\B8\AD\E0\B8\87\E0\B9\80\E0\B8\A3\E0\B8\B5\
    \E0\B8\A2\E0\B8\81 Cloudflare\
    \n# \E0\B8\96\E0\B9\89\E0\B8\B2\E0\B8\A1\E0\B8\B5\E0\B8\84\E0\B9\88\E0\B8\
    \B2\E0\B9\80\E0\B8\81\E0\B9\88\E0\B8\B2\E0\B8\AD\E0\B8\A2\E0\B8\B9\E0\B9\
    \88\E0\B9\81\E0\B8\A5\E0\B9\89\E0\B8\A7 \E0\B9\81\E0\B8\A5\E0\B8\B0\E0\B9\
    \80\E0\B8\97\E0\B9\88\E0\B8\B2\E0\B8\81\E0\B8\B1\E0\B8\9A currentIP \E2\86\
    \92 \E0\B8\82\E0\B9\89\E0\B8\B2\E0\B8\A1\
    \n:if (\$cfLastIP = \$currentIP) do={\
    \n    :log info (\"CF-DDNS: IP unchanged (\" . \$currentIP . \"), skip upd\
    ate\");\
    \n\
    \n} else={\
    \n\
    \n    # ---- \E0\B9\80\E0\B8\95\E0\B8\A3\E0\B8\B5\E0\B8\A2\E0\B8\A1 Header\
    \_\E0\B8\AA\E0\B8\B3\E0\B8\AB\E0\B8\A3\E0\B8\B1\E0\B8\9A Cloudflare API --\
    --\
    \n    :local authHeader (\"Authorization: Bearer \" . \$cfToken);\
    \n    :local ctHeader \"Content-Type: application/json\";\
    \n    :local headers (\$authHeader . \",\" . \$ctHeader);\
    \n\
    \n    # 3) \E0\B8\94\E0\B8\B6\E0\B8\87 DNS record \E0\B8\88\E0\B8\B2\E0\B8\
    \81 Cloudflare \E0\B9\80\E0\B8\9E\E0\B8\B7\E0\B9\88\E0\B8\AD\E0\B8\AB\E0\
    \B8\B2 recordID \E0\B8\95\E0\B8\B2\E0\B8\A1\E0\B8\8A\E0\B8\B7\E0\B9\88\E0\
    \B8\AD ddnsName\
    \n    /tool fetch url=(\"https://api.cloudflare.com/client/v4/zones/\" . \
    \$zoneID . \"/dns_records\?type=A&name=\" . \$ddnsName) mode=https http-me\
    thod=get http-header-field=\$authHeader dst-path=cf-ddns.json;\
    \n\
    \n    :delay 1;\
    \n\
    \n    :local cfJson [/file get cf-ddns.json contents];\
    \n\
    \n    :if ([:len \$cfJson] = 0) do={\
    \n        :log error \"CF-DDNS: empty JSON from Cloudflare\";\
    \n        :return;\
    \n    }\
    \n\
    \n    # 4) \E0\B8\94\E0\B8\B6\E0\B8\87 recordID \E0\B8\AD\E0\B8\AD\E0\B8\
    \81\E0\B8\88\E0\B8\B2\E0\B8\81 JSON (\E0\B9\83\E0\B8\8A\E0\B9\89\E0\B8\84\
    \E0\B8\A7\E0\B8\B2\E0\B8\A1\E0\B8\A2\E0\B8\B2\E0\B8\A7 key \E0\B8\9B\E0\B9\
    \89\E0\B8\AD\E0\B8\87\E0\B8\81\E0\B8\B1\E0\B8\99\E0\B8\95\E0\B8\B1\E0\B8\
    \94\E0\B9\80\E0\B8\A5\E0\B8\82\E0\B8\95\E0\B8\B1\E0\B8\A7\E0\B8\AB\E0\B8\
    \99\E0\B9\89\E0\B8\B2)\
    \n    :local recordID \"\";\
    \n    :local idKey \"\\\"id\\\":\\\"\";\
    \n    :local ridStart [:find \$cfJson \$idKey];\
    \n\
    \n    :if (\$ridStart != nil) do={\
    \n        :set ridStart (\$ridStart + [:len \$idKey]);\
    \n        :local ridEnd [:find \$cfJson \"\\\"\" \$ridStart];\
    \n        :set recordID [:pick \$cfJson \$ridStart \$ridEnd];\
    \n    }\
    \n\
    \n    :if (\$recordID = \"\") do={\
    \n        :log error (\"CF-DDNS: A record for \" . \$ddnsName . \" not fou\
    nd on Cloudflare. Please create it first.\");\
    \n        :return;\
    \n    }\
    \n\
    \n    # 5) \E0\B9\80\E0\B8\95\E0\B8\A3\E0\B8\B5\E0\B8\A2\E0\B8\A1 JSON \E0\
    \B8\AA\E0\B8\B3\E0\B8\AB\E0\B8\A3\E0\B8\B1\E0\B8\9A\E0\B8\AD\E0\B8\B1\E0\
    \B8\9B\E0\B9\80\E0\B8\94\E0\B8\95 IP\
    \n    :local jUp (\"{\\\"type\\\":\\\"A\\\",\\\"name\\\":\\\"\" . \$ddnsNa\
    me . \"\\\",\\\"content\\\":\\\"\" . \$currentIP . \"\\\",\\\"ttl\\\":120,\
    \\\"proxied\\\":false}\");\
    \n\
    \n    :log info (\"CF-DDNS: updating \" . \$ddnsName . \" to \" . \$curren\
    tIP);\
    \n\
    \n    # 6) \E0\B8\AD\E0\B8\B1\E0\B8\9B\E0\B9\80\E0\B8\94\E0\B8\95 DNS reco\
    rd \E0\B8\9A\E0\B8\99 Cloudflare\
    \n    /tool fetch url=(\"https://api.cloudflare.com/client/v4/zones/\" . \
    \$zoneID . \"/dns_records/\" . \$recordID) mode=https http-method=put http\
    -data=\$jUp http-header-field=\$headers dst-path=cf-update.json;\
    \n\
    \n    # 7) \E0\B9\80\E0\B8\8B\E0\B8\9F IP \E0\B8\A5\E0\B9\88\E0\B8\B2\E0\
    \B8\AA\E0\B8\B8\E0\B8\94\E0\B8\A5\E0\B8\87 global cfLastIP\
    \n    :set cfLastIP \$currentIP;\
    \n\
    \n    :log info \"CF-DDNS: update request sent.\";\
    \n}"

