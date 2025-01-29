# pg_tunity
Postgresql Tune Utility

## How to Use

### Getting help -h
``` bash
root@postgresql-server:/home/deren# bash pg_tuner.sh -h
Kullanım: pg_tuner.sh [-m <ram_gb>] [-c <cpu_cores> <ram_gb>] [-o <yol>] [-h]
-m <ram_gb>: Sistemdeki RAM miktarını manuel olarak belirleyin (GB cinsinden)
-c <cpu_cores> <ram_gb>: CPU çekirdek sayısını ve RAM miktarını manuel olarak belirleyin (CPU çekirdek sayısı ve RAM GB cinsinden)
-o <yol>: Konfigürasyon dosyasını belirtilen dizine kaydet
-h: Yardım mesajını görüntüle
```

### Basic Usage
``` bash
root@postgresql-server:/home/deren# bash pg_tuner.sh
```
**Üretilen config örneği**
``` bash
root@postgresql-server:/home/deren# cat postgresql.conf
# PostgreSQL Konfigürasyon Dosyası
# Otomatik olarak oluşturulmuştur.

# Bellek Ayarları
shared_buffers = 768MB      # RAM'in 1/4'ü
work_mem = 192kB                  # RAM'in 1/16'sı
maintenance_work_mem = 384MB  # RAM'in 1/8'i
effective_cache_size = 2048MB  # RAM'in 2/3'ü

# İşlemci Ayarları
# CPU core sayısına göre paralel işlem ayarlarını yapabiliriz, ancak burada temel ayarları kullanıyoruz
max_parallel_workers_per_gather = 4  # CPU sayısı kadar paralel işlem

# Diğer Genel Ayarlar
# Yüksek performans için bu değerler değiştirilmiştir
shared_preload_libraries = 'pg_stat_statements'  # Statik sorgu analizini aktif et
autovacuum = on  # Otomatik temizlik işlemleri açık
autovacuum_max_workers = 3  # Maksimum 3 otomatik temizlik işçisi

# Loglama Ayarları
log_min_duration_statement = 1000  # 1 saniye üzerinde sorgular loglanacak

# Bu dosya PostgreSQL için optimize edilmiştir.
```


