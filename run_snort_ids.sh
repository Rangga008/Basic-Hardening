#!/bin/bash

# Konfigurasi
INTERFACE="eth0"  # Ganti dengan interface utama (misalnya ens33, enp0s3, dll)
SNORT_CONF="/etc/snort/snort.conf"
LOG_DIR="$HOME/snort_logs"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILE="$LOG_DIR/snort_alert_$DATE.log"
REPORT_FILE="$LOG_DIR/laporan_snort_$DATE.txt"
NAMA_PESERTA="Kuren"  # Ganti nama kamu yaa~

# Buat folder log kalau belum ada
mkdir -p "$LOG_DIR"

echo "🛡️ Menjalankan Snort IDS di interface $INTERFACE..."
sudo snort -i "$INTERFACE" -A console -c "$SNORT_CONF" -l "$LOG_DIR" -K ascii > "$LOG_FILE"

echo "📁 Log disimpan di: $LOG_FILE"

# Membuat laporan dari hasil log
echo "📝 Membuat laporan otomatis..."

echo "===== LAPORAN ANALISA SNORT - MODE IDS =====" > "$REPORT_FILE"
echo "Nama Peserta  : $NAMA_PESERTA" >> "$REPORT_FILE"
echo "Interface     : $INTERFACE" >> "$REPORT_FILE"
echo "Waktu Uji     : $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "--- ALERT TERDETEKSI ---" >> "$REPORT_FILE"

# Ekstrak alert dari log
grep "\[\*\*\]" "$LOG_FILE" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "--- ANALISIS SINGKAT ---" >> "$REPORT_FILE"
echo "Log di atas menunjukkan alert dari Snort selama monitoring." >> "$REPORT_FILE"
echo "Perlu dilakukan pemeriksaan terhadap jenis serangan dan IP yang terlibat." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "===== END OF REPORT =====" >> "$REPORT_FILE"

echo "✅ Laporan selesai: $REPORT_FILE"
