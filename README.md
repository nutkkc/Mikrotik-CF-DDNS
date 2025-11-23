# Mikrotik-CF-DDNS
Script Mikrotik CloudFlare API IP DDNS Update

สคริปต์นี้ใช้สำหรับทำ **Dynamic DNS (DDNS)** บน MikroTik โดยอัปเดตค่า A record บน **Cloudflare** อัตโนมัติ  
ผ่าน Cloudflare API และใช้ `:resolve myip.opendns.com` เพื่อดึง **Public IP จริง** ของเรา

สคริปต์หลักอยู่ในไฟล์:

- `mikrotik_ddns.rsc`

> รองรับ RouterOS v6 / v7 (ทดสอบบน v7 แล้วทำงานได้จริง)

## ฟีเจอร์

- ใช้ Cloudflare API (แบบใช้ **API Token** ไม่ใช่ Global API Key)
- หา Public IP ผ่าน OpenDNS: `:resolve myip.opendns.com server=208.67.222.222`
- มีตัวแปร global (`cfLastIP`) จำ IP ล่าสุด  
  → ถ้า IP ยังเหมือนเดิม **จะไม่ยิง API ไปอัปเดตซ้ำ**
- ใช้ A record ที่มีอยู่แล้ว (แนะนำให้สร้างใน Cloudflare ก่อน)
- การทำงานให้ทำงานผ่าน scheduler ให้รันทุก x นาที

## 1. การตั้งค่าตัวแปรในสคริปต์

ในไฟล์ `mikrotik_ddns.rsc` ให้แก้ส่วนนี้:

```rsc
:local cfToken "token";
:local zoneID "zoneid";
:local ddnsName "dnsname.domain.xyz";
```

### 1.1 หา `cfToken`

1. Cloudflare Dashboard → Profile → API Tokens  
2. Create Token → **Edit zone DNS**  
3. เลือก Specific Zone → เลือกโดเมนของคุณ  
4. คัดลอก Token มาใส่ในสคริปต์

### 1.2 หา `zoneID`

1. Cloudflare Dashboard  
2. เลือกโดเมน  
3. หน้า Overview → มองหาหัวข้อ API → Zone ID

### 1.3 ตั้งค่า `ddnsName`

1. Cloudflare → DNS → Add Record  
2. Type: A  
3. Name: เช่น `home` (FQDN จะเป็น `home.example.com`)  
4. IPv4: ใส่อะไรก็ได้ เช่น `1.1.1.1` เดี๋ยวสคริปต์อัปเดตให้เอง

## 2. นำสคริปต์เข้า MikroTik

ใช้คำสั่ง:

```rsc
/import file-name=mikrotik_ddns.rsc
```

หรือสร้าง script ใหม่แล้ว paste source ลงไป

## 3. ทดสอบสคริปต์

```rsc
/system script run cloudflare-ddns
/log print where message~"CF-DDNS"
```

## 4. ตั้งรันอัตโนมัติทุก 5 นาที

```rsc
/system scheduler add name=cloudflare-ddns interval=5m on-event="cloudflare-ddns"
```

## License

MIT License (หรือระบุของคุณเอง)
