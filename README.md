# Perbandingan Metode K-Means, K-Medoids, dan AHC Ward dalam Klasterisasi Kabupaten/Kota di Indonesia Berdasarkan Indikator IPM

Repositori ini berisi *source code* R dan dataset yang digunakan dalam penelitian artikel ilmiah publikasi Bandung Conference Series: Statistics. Riset ini melakukan komparasi performa tiga algoritma klasterisasi untuk mengelompokkan 514 Kabupaten/Kota di Indonesia berdasarkan indikator Indeks Pembangunan Manusia (IPM) tahun 2024.

---

## 1. Latar Belakang & Tujuan

Penentuan strategi pembangunan daerah yang efektif memerlukan pemetaan indikator kesejahteraan yang akurat. Proyek ini membandingkan tiga metode klasterisasi populer:
1. **K-Means Clustering** (Berbasis *Centroid*)
2. **K-Medoids Clustering / PAM** (Berbasis *Medoid*, lebih tebal terhadap *outlier*)
3. **Agglomerative Hierarchical Clustering (AHC) Metode Ward** (Berbasis Hirarki)

**Tujuan Penelitian:**
* Melakukan normalisasi data menggunakan metode *Min-Max Scaling*.
* Menguji variasi jumlah klaster dari $k = 2$ hingga $k = 20$.
* Mengevaluasi kualitas klasterisasi terbaik menggunakan **Calinski-Harabasz Index (CHI)** untuk menentukan metode yang paling optimal.

---

## 2. Indikator Data (IPM BPS 2024)

Klasterisasi dilakukan pada 514 entitas Kabupaten/Kota dengan menggunakan 4 indikator utama IPM dari Badan Pusat Statistik (BPS):
1. **UHH** (Umur Harapan Hidup)
2. **HLS** (Harapan Lama Sekolah)
3. **RLS** (Rata-rata Lama Sekolah)
4. **Pengeluaran Per Kapita** yang disesuaikan.

---

## 3. Alur Implementasi Kode R (`src/spesia.R`)

Tahapan penulisan kode dalam riset ini diimplementasikan menggunakan bahasa R dengan beberapa *library* utama seperti `cluster`, `clusterCrit`, dan `ggplot2`.

### 3.1 Preprocessing: Normalisasi Min-Max
Sebelum proses klasterisasi, dilakukan transformasi data agar perbedaan satuan antar-indikator tidak memengaruhi bobot perhitungan jarak euclidian.
```R
minmax_scaling <- function(x) (x - min(x)) / (max(x) - min(x))
data_minmax <- as.data.frame(lapply(df, minmax_scaling))
```

### 3.2 Iterasi K otomatis & Evaluasi Calinski-Harabasz
Script menjalankan perulangan (*looping*) dari klaster $k = 2$ hingga $k = 20$ untuk mengekstrak nilai indeks kualitas internal secara simultan.
```R
for (k in 2:20) {
  -- KMeans --
  km <- kmeans(data_minmax, centers = k, nstart = 10)
  ch_km <- intCriteria(as.matrix(df), as.integer(km$cluster), "Calinski_Harabasz")[[1]]
  
  -- KMedoids (PAM) --
  pam_res <- pam(data_minmax, k = k)
  ch_pam <- intCriteria(as.matrix(df), as.integer(pam_res$cluster), "Calinski_Harabasz")[[1]]
  
  -- AHC Ward --
  hc_ward <- hclust(dist(data_minmax), method = "ward.D2")
  sub_grp <- cutree(hc_ward, k = k)
  ch_ahc <- intCriteria(as.matrix(df), as.integer(sub_grp), "Calinski_Harabasz")[[1]]
}
```

---

## 4. Hasil Evaluasi & Kesimpulan Artikel

Berdasarkan pengujian nilai tertinggi *Calinski-Harabasz Index* (CHI), diperoleh ringkasan performa sebagai berikut:

| Metode Klaster | Jumlah Klaster Optimal ($k$) | Nilai Calinski-Harabasz Index (CHI) | Kesimpulan |
| :--- | :---: | :---: | :--- |
| **K-Medoids** | $k = 2$ | **424.01** | **Paling Optimal** (Nilai CHI Tertinggi) |
| **K-Means** | $k = 2$ | 407.26 | Optimal pada struktur partisi 2 kelompok |
| **AHC Ward** | $k = 3$ | 301.17 | Struktur hirarki terbaik pada 3 kelompok |

**Kesimpulan Utama:** Metode **K-Medoids** dengan pembagian $k=2$ kelompok menghasilkan pemisahan klaster kabupaten/kota yang paling solid dan homogen. Hal ini dipengaruhi oleh karakteristik data IPM Indonesia yang memiliki beberapa daerah *outlier* ekstrem, di mana K-Medoids terbukti lebih kebal (*robust*) menangani *outlier* dibandingkan K-Means.

---

## 5. Cara Menjalankan Code

1. Clone repositori ini ke komputer Anda:
   ```bash
   git clone [https://github.com/username](https://github.com/username) Anda/Indonesian-HDI-Clustering-Comparison-R.git
   ```
2. Pastikan Anda telah menginstal packages yang diperlukan di R/RStudio:
   ```R
   install.packages(c("readxl", "openxlsx", "cluster", "clusterCrit", "ggplot2"))
   ```
3. Buka file `src/spesia.R`, sesuaikan *working directory* (`setwd`), dan jalankan script.

---

## Citation / Sitasi
Jika Anda menggunakan kode atau bagian dari penelitian ini untuk keperluan akademik, silakan merujuk ke artikel publikasi resmi kami:
```text
Kuswara, S. R. P., & Roshafara, F. (2025). Perbandingan Metode K-Means, K-Medoids, dan AHC Ward dalam Klasterisasi Kabupaten/Kota di Indonesia berdasarkan Indikator IPM. Bandung Conference Series: Statistics, 5(2), 191-200.
URL: [https://doi.org/10.29313/bcss.v5i2.18431](https://doi.org/10.29313/bcss.v5i2.18431)
```
