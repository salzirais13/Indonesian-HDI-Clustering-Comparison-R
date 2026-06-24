setwd("D:/kuliah/skripsi/spesia")
library(readxl)
library(openxlsx)
library(cluster)
library(clusterCrit)
library(ggplot2)

# Baca dan siapkan data
data <- read_excel("data awal.xlsx")
data1 <- na.omit(data)
df <- data1[-1]

# Normalisasi Min-Max
minmax_scaling <- function(x) (x - min(x)) / (max(x) - min(x))
data_minmax <- as.data.frame(lapply(df, minmax_scaling))

# Inisialisasi data frame untuk tiap metode
kmeans_df <- data.frame(K = integer(), Calinski = numeric())
kmedoids_df <- data.frame(K = integer(), Calinski = numeric())
ahc_df <- data.frame(K = integer(), Calinski = numeric())

# Looping dari k = 2 sampai 20
for (k in 2:20) {
  # --- KMeans ---
  km <- kmeans(data_minmax, centers = k, nstart = 10)
  ch_km <- intCriteria(as.matrix(df), as.integer(km$cluster), "Calinski_Harabasz")[[1]]
  kmeans_df <- rbind(kmeans_df, data.frame(K = k, Calinski = ch_km))
  
  # --- KMedoids ---
  pam_res <- pam(data_minmax, k = k)
  ch_pm <- intCriteria(as.matrix(df), as.integer(pam_res$cluster), "Calinski_Harabasz")[[1]]
  kmedoids_df <- rbind(kmedoids_df, data.frame(K = k, Calinski = ch_pm))
  
  # --- AHC Ward ---
  dist_mat <- dist(data_minmax)
  hc <- hclust(dist_mat, method = "ward.D2")
  hc_labels <- cutree(hc, k = k)
  ch_hc <- intCriteria(as.matrix(df), as.integer(hc_labels), "Calinski_Harabasz")[[1]]
  ahc_df <- rbind(ahc_df, data.frame(K = k, Calinski = ch_hc))
}

# -----------------------------
# PLOT TERPISAH PER METODE
# -----------------------------
ggplot(kmeans_df, aes(x = K, y = Calinski)) +
  geom_line(color = "blue", linewidth = 1.2) +
  geom_point(color = "blue", size = 2) +
  labs(title = "K-Means: Calinski-Harabasz Index",
       x = "Jumlah Klaster (k)", y = "Calinski-Harabasz Index") +
  theme_minimal()

ggplot(kmedoids_df, aes(x = K, y = Calinski)) +
  geom_line(color = "darkgreen", linewidth = 1.2) +
  geom_point(color = "darkgreen", size = 2) +
  labs(title = "K-Medoids: Calinski-Harabasz Index",
       x = "Jumlah Klaster (k)", y = "Calinski-Harabasz Index") +
  theme_minimal()

ggplot(ahc_df, aes(x = K, y = Calinski)) +
  geom_line(color = "red", linewidth = 1.2) +
  geom_point(color = "red", size = 2) +
  labs(title = "AHC Ward: Calinski-Harabasz Index",
       x = "Jumlah Klaster (k)", y = "Calinski-Harabasz Index") +
  theme_minimal()
# -----------------------------
# DENDOGRAM AHC WARD
# -----------------------------
# Hitung matriks jarak menggunakan data hasil normalisasi
dist_ahc <- dist(data_minmax, method = "euclidean")

# Lakukan agglomerasi dengan metode Ward
hc_ward <- hclust(dist_ahc, method = "ward.D2")

# Plot dendogram
plot(hc_ward, labels = FALSE, hang = -1, 
     main = "Dendogram AHC Ward", 
     xlab = "", ylab = "Jarak", sub = "")
# -----------------------------
# TULIS KE EXCEL (opsional)
# -----------------------------
write.xlsx(kmeans_df, "chi_kmeans.xlsx")
write.xlsx(kmedoids_df, "chi_kmedoids.xlsx")
write.xlsx(ahc_df, "chi_ahc_ward.xlsx")
