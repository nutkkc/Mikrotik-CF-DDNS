# ==========================
# Cloudflare DDNS for MikroTik
# - ใช้ :resolve myip.opendns.com หาค่า Public IP
# - ใช้ global cfLastIP เก็บ IP ล่าสุด
# - ถ้า IP เดิม = IP ใหม่ → ไม่ต้องเรียก Cloudflare
# ==========================

#
#add interval=5m name=dyndns on-event="/system/script/run dyndns" policy=\
#    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
#    start-date=2025-11-23 start-time=23:00:00

:local cfToken "cfToken";
:local zoneID "zoneID";
:local ddnsName "ddnsName.ddnsName.xyz";


:local envid [/system script environment find where name="cfLastIP"]
:global cfLastIP;

:if ($envid = "" ) do={
    :set cfLastIP ""
}

# ---- เตรียม global สำหรับเก็บ IP ล่าสุด (ครั้งแรกให้สร้างเป็นว่าง) ----
#:if ([:len [/system script environment find name="cfLastIP"]] = 0) do={
#    :global cfLastIP "";
#}


# 1) ดึง IP ปัจจุบันจาก OpenDNS (Public IP)
:local currentIP [:resolve myip.opendns.com server=208.67.222.222];

:if ([:len "$currentIP"] = 0) do={
    :log warning "CF-DDNS: cannot resolve public IP from OpenDNS";
    :return;
}

# 2) ถ้ามีค่าเก่าอยู่แล้ว และ IP เดิม = IP ใหม่ → ข้าม ไม่ต้องเรียก Cloudflare
# ถ้ามีค่าเก่าอยู่แล้ว และเท่ากับ currentIP → ข้าม
:if ($cfLastIP = $currentIP) do={
    :log info ("CF-DDNS: IP unchanged (" . $currentIP . "), skip update");

} else={

    # ---- เตรียม Header สำหรับ Cloudflare API ----
    :local authHeader ("Authorization: Bearer " . $cfToken);
    :local ctHeader "Content-Type: application/json";
    :local headers ($authHeader . "," . $ctHeader);

    # 3) ดึง DNS record จาก Cloudflare เพื่อหา recordID ตามชื่อ ddnsName
    /tool fetch url=("https://api.cloudflare.com/client/v4/zones/" . $zoneID . "/dns_records?type=A&name=" . $ddnsName) mode=https http-method=get http-header-field=$authHeader dst-path=cf-ddns.json;

    :delay 1;

    :local cfJson [/file get cf-ddns.json contents];

    :if ([:len $cfJson] = 0) do={
        :log error "CF-DDNS: empty JSON from Cloudflare";
        :return;
    }

    # 4) ดึง recordID ออกจาก JSON (ใช้ความยาว key ป้องกันตัดเลขตัวหน้า)
    :local recordID "";
    :local idKey "\"id\":\"";
    :local ridStart [:find $cfJson $idKey];

    :if ($ridStart != nil) do={
        :set ridStart ($ridStart + [:len $idKey]);
        :local ridEnd [:find $cfJson "\"" $ridStart];
        :set recordID [:pick $cfJson $ridStart $ridEnd];
    }

    :if ($recordID = "") do={
        :log error ("CF-DDNS: A record for " . $ddnsName . " not found on Cloudflare. Please create it first.");
        :return;
    }

    # 5) เตรียม JSON สำหรับอัปเดต IP
    :local jUp ("{\"type\":\"A\",\"name\":\"" . $ddnsName . "\",\"content\":\"" . $currentIP . "\",\"ttl\":120,\"proxied\":false}");

    :log info ("CF-DDNS: updating " . $ddnsName . " to " . $currentIP);

    # 6) อัปเดต DNS record บน Cloudflare
    /tool fetch url=("https://api.cloudflare.com/client/v4/zones/" . $zoneID . "/dns_records/" . $recordID) mode=https http-method=put http-data=$jUp http-header-field=$headers dst-path=cf-update.json;

    # 7) เซฟ IP ล่าสุดลง global cfLastIP
    :set cfLastIP $currentIP;


    :log info "CF-DDNS: update request sent.";
}
