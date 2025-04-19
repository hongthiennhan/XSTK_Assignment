# ---------- [Đọc thông tin dữ liệu] ---------- #
# Đọc dữ liệu từ file CSV
llm_data <- read.csv("D:/HCMUT/XSTK/XSTK_Assignment/data/llm_comparison_dataset.csv")
numeric_cols <- sapply(llm_comparison, function(x) typeof(x) == "double")

# Kiểm tra kích thước (số dòng, số cột)
cat("Số dòng:", nrow(llm_data), "\n")
cat("Số cột:", ncol(llm_data), "\n")

# Tên các cột
cat("Tên các cột:\n")
print(colnames(llm_data))

# Kiểm tra kiểu dữ liệu và cấu trúc
str(llm_data)

# Xem 6 dòng đầu tiên của dữ liệu
head(llm_data)

# Tóm tắt thống kê cho tất cả các cột
summary(llm_data)

# ---------- [Làm sạch dữ liệu] ---------- #
# ---------- [Kiểm tra dữ liệu khuyết] ---------- #
# Kiểm tra dữ liệu khuyết
missing_data_summary <- sapply(llm_data, function(x) {
  total_missing <- sum(is.na(x))
  percent_missing <- (total_missing / length(x)) * 100
  return(c(Total_missing = total_missing, Percent_missing = percent_missing))
})
as.data.frame(t(missing_data_summary))
print(missing_data_summary)

# ---------- [Kiểm tra dữ liệu ngoại lai] ---------- #
# Kiểm tra dữ liệu ngoại lai
count_and_ratio_outliers <- function(x) {
  iqr <- IQR(x)
  lower <- quantile(x, 0.25) - 1.5 * iqr
  upper <- quantile(x, 0.75) + 1.5 * iqr
  num_outliers <- sum(x < lower | x > upper)
  ratio_outliers <- num_outliers / length(x) * 100
  return(c(Count = num_outliers, Ratio = ratio_outliers))
}
numeric_vars <- llm_data[sapply(llm_data, is.numeric)]
t(sapply(numeric_vars, count_and_ratio_outliers))

# Thay thế dữ liệu ngoại lai bằng mean
replace_outliers_with_mean <- function(x) {
  if (!is.numeric(x)) return(x)
  
  iqr <- IQR(x)
  lower <- quantile(x, 0.25) - 1.5 * iqr
  upper <- quantile(x, 0.75) + 1.5 * iqr
  mean_value <- mean(x)
  
  x[x < lower | x > upper] <- mean_value
  return(x)
}
llm_data[] <- lapply(llm_data, replace_outliers_with_mean)
print(llm_data)

# Chuyển đổi Provider sang factor
llm_data$Model <- as.factor(llm_data$Model)
str(llm_data)
levels(llm_data$Model)

# ---------- [Thống kê mô tả] ---------- #
# Tính toán các thống kê mô tả: mean, sd, min, Q1, median, Q3, max
numeric_vars <- llm_data[sapply(llm_data, is.numeric)]
summary_stat <- sapply(numeric_vars, function(x) {
  c(
    Mean = mean(x),
    SD = sd(x),
    Min = min(x),
    Q1 = quantile(x, 0.25),
    Median = median(x),
    Q3 = quantile(x, 0.75),
    Max = max(x)
  )
})

# Chuyển về data frame
summary_df <- as.data.frame(t(summary_stat))
print(summary_df)
table(llm_data$Model)

# ---------- [Vẽ đồ thị Histogram] ---------- #
png("output/figures/histograms.png", width = 1280, height = 720)
numeric_num <- llm_comparison[ , numeric_cols]
par(mfrow = c(1, 3))
for (col in names(numeric_num)) { 
  hist(numeric_vars[[col]], main = paste("Histogram of", col), xlab = col, col = 
         "lightblue", border = "black") 
}
dev.off()

# ---------- [Vẽ đồ thị Box Plot] ---------- #
png("output/figures/boxplots.png", width = 1280, height = 720)
par(mfrow = c(1, 3))
boxplot(`Latency..sec.` ~ Model, data = llm_data,
        main = "Latency (sec) by Model", col = "lightgreen")
boxplot(`Price...Million.Tokens` ~ Model, data = llm_data,
        main = "Price / Million Tokens by Model", col = "lightgreen")
boxplot(`Energy.Efficiency` ~ Model, data = llm_data,
        main = "Energy Efficiency by Model", col = "lightgreen")
dev.off()

# --------------------------------------------------------------------- #

# Lọc dữ liệu có đầy đủ thông tin
latency_data <- llm_data[!is.na(llm_data$Latency..sec.) & !is.na(llm_data$Model), ]

# ANOVA
anova_latency <- aov(Latency..sec. ~ Model, data = latency_data)
summary(anova_latency)

# Kiểm định giả thuyết:
  # H0: Độ trễ trung bình giữa các nhà cung cấp là như nhau
  # H1: Có ít nhất một nhà cung cấp có độ trễ trung bình khác biệt
# Nếu p-value < 0.05 → Bác bỏ H0 → Có sự khác biệt có ý nghĩa

# Kết quả: 0.05 < p < 0.1: "Có xu hướng khác biệt về độ trễ giữa các nhà cung cấp, nhưng chưa đủ mạnh để kết luận một cách chắc chắn ở mức ý nghĩa 5%."

model1 <- lm(Latency..sec. ~ Speed..tokens.sec. + Compute.Power, data = llm_data)
summary(model1)

cor.test(llm_data$Latency..sec., llm_data$Speed..tokens.sec., method = "pearson")
cor.test(llm_data$Latency..sec., llm_data$Compute.Power, method = "pearson")


library(ggplot2)

# Vẽ biểu đồ phân tán (scatter plot)
ggplot(llm_data, aes(x = Speed..tokens.sec., y = Latency..sec.)) + 
  geom_point() + 
  geom_smooth(method = "lm") + 
  labs(title = "Latency vs Speed")

ggplot(llm_data, aes(x = Compute.Power, y = Latency..sec.)) + 
  geom_point() + 
  geom_smooth(method = "lm") + 
  labs(title = "Latency vs Compute Power")

cor_matrix <- cor(llm_data, use = "complete.obs")
cor_matrix["Latency", ]

model_all <- lm(Latency ~ ., data = llm_data)
summary(model_all)





