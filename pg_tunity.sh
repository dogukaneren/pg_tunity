#!/bin/bash

function show_help {
    echo "Kullanım: $0 [-m <ram_gb>] [-c <cpu_cores> <ram_gb>] [-o <yol>] [-h]"
    echo "-m <ram_gb>: Sistemdeki RAM miktarını manuel olarak belirleyin (GB cinsinden)"
    echo "-c <cpu_cores> <ram_gb>: CPU çekirdek sayısını ve RAM miktarını manuel olarak belirleyin (CPU çekirdek sayısı ve RAM GB cinsinden)"
    echo "-o <yol>: Konfigürasyon dosyasını belirtilen dizine kaydet"
    echo "-h: Yardım mesajını görüntüle"
}

RAM_GB=""
CPU_CORES=""
OUTPUT_PATH="./postgresql.conf"

while getopts "m:c:o:h" opt; do
    case $opt in
        m)
            RAM_GB=$OPTARG
            ;;
        c)
            CPU_CORES=$(echo $OPTARG | awk '{print $1}')
            RAM_GB=$(echo $OPTARG | awk '{print $2}')
            ;;
        o)
            OUTPUT_PATH=$OPTARG
            ;;
        h)
            show_help
            exit 0
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
done

if [ -z "$RAM_GB" ]; then
    RAM_GB=$(free -g | grep Mem | awk '{print $2}')
    if [ -z "$RAM_GB" ]; then
        echo "RAM miktarı belirlenemedi ve manuel olarak verilmedi."
        exit 1
    fi
fi

if [ -z "$CPU_CORES" ]; then
    CPU_CORES=$(nproc)
    if [ -z "$CPU_CORES" ]; then
        echo "CPU çekirdek sayısı belirlenemedi ve manuel olarak verilmedi."
        exit 1
    fi
fi

shared_buffers=$((RAM_GB * 1024 / 4))  # 1/4 RAM for shared_buffers
work_mem=$((RAM_GB * 1024 / 16))  # 1/16 RAM for work_mem
maintenance_work_mem=$((RAM_GB * 1024 / 8))  # 1/8 RAM for maintenance_work_mem
effective_cache_size=$((RAM_GB * 1024 * 2 / 3))  # 2/3 of RAM for effective_cache_size

cat > $OUTPUT_PATH << EOF
# PostgreSQL Konfigürasyon Dosyası
# Otomatik olarak oluşturulmuştur.

# Bellek Ayarları
shared_buffers = ${shared_buffers}MB      # RAM'in 1/4'ü
work_mem = ${work_mem}kB                  # RAM'in 1/16'sı
maintenance_work_mem = ${maintenance_work_mem}MB  # RAM'in 1/8'i
effective_cache_size = ${effective_cache_size}MB  # RAM'in 2/3'ü

# İşlemci Ayarları
# CPU core sayısına göre paralel işlem ayarlarını yapabiliriz, ancak burada temel ayarları kullanıyoruz
max_parallel_workers_per_gather = $CPU_CORES  # CPU sayısı kadar paralel işlem

# Diğer Genel Ayarlar
# Yüksek performans için bu değerler değiştirilmiştir
shared_preload_libraries = 'pg_stat_statements'  # Statik sorgu analizini aktif et
autovacuum = on  # Otomatik temizlik işlemleri açık
autovacuum_max_workers = 3  # Maksimum 3 otomatik temizlik işçisi

# Loglama Ayarları
log_min_duration_statement = 1000  # 1 saniye üzerinde sorgular loglanacak

# Bu dosya PostgreSQL için optimize edilmiştir.
EOF

echo "PostgreSQL konfigürasyon dosyası başarıyla oluşturuldu: $OUTPUT_PATH"
