# ---------- [Đọc thông tin dữ liệu] ---------- #
# Đọc dữ liệu từ file CSV
llm_data <- read.csv("D:/HCMUT/XSTK/XSTK_Assignment/data/llm_comparison_dataset.csv")

# Đặt lại tên biến
names(llm_data)[names(llm_data) == "Speed..tokens.sec."] <- "Speed"
names(llm_data)[names(llm_data) == "Latency..sec."] <- "Latency"
names(llm_data)[names(llm_data) == "Benchmark..MMLU."] <- "Benchmark.MMLU"
names(llm_data)[names(llm_data) == "Benchmark..Chatbot.Arena."] <- "Benchmark.Chatbot.Arena."
names(llm_data)[names(llm_data) == "Price...Million.Tokens"] <- "Price"
names(llm_data)[names(llm_data) == "Training.Dataset.Size"] <- "Dataset.Size"
names(llm_data)[names(llm_data) == "Energy.Efficiency"] <- "Efficiency"

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
llm_data$Provider <- as.factor(llm_data$Provider)
str(llm_data)
levels(llm_data$Provider)

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
table(llm_data$Provider)

# ---------- [Vẽ đồ thị Histogram] ---------- #
png("output/figures/histograms.png", width = 1280, height = 720)
print(colnames(llm_data))
par(mfrow = c(2, 3))

hist(llm_data$Speed, 
     main = "Histogram of Speed (tokens/sec)", 
     xlab = "Speed (tokens/sec)", 
     col = "lightblue", 
     border = "black")

hist(llm_data$Latency, 
     main = "Histogram of Latency (sec)", 
     xlab = "Latency (sec)", 
     col = "lightblue", 
     border = "black")

hist(llm_data$Price, 
     main = "Histogram of Price / Million Tokens", 
     xlab = "Price / Million Tokens", 
     col = "lightblue", 
     border = "black")

hist(llm_data$Dataset.Size, 
     main = "Histogram of Training Dataset Size", 
     xlab = "Training Dataset Size", 
     col = "lightblue", 
     border = "black")

hist(llm_data$Compute.Power, 
     main = "Histogram of Compute Power", 
     xlab = "Compute Power", 
     col = "lightblue", 
     border = "black")

hist(llm_data$Efficiency, 
     main = "Histogram of Energy Efficiency", 
     xlab = "Energy Efficiency", 
     col = "lightblue", 
     border = "black")
dev.off()

# ---------- [Vẽ đồ thị Box Plot một biến] ---------- #
png("output/figures/boxplots.png", width = 1280, height = 720)
par(mfrow = c(2, 3))

boxplot(llm_data$Speed, 
     main = "Boxplot of Speed (tokens/sec)", 
     xlab = "Speed (tokens/sec)", 
     col = "lightgreen", 
     border = "black")

boxplot(llm_data$Latency, 
     main = "Boxplot of Latency (sec)", 
     xlab = "Latency (sec)", 
     col = "lightgreen", 
     border = "black")

boxplot(llm_data$Price, 
     main = "Boxplot of Price / Million Tokens", 
     xlab = "Price / Million Tokens", 
     col = "lightgreen", 
     border = "black")

boxplot(llm_data$Dataset.Size, 
     main = "Boxplot of Training Dataset Size", 
     xlab = "Training Dataset Size", 
     col = "lightgreen", 
     border = "black")

boxplot(llm_data$Compute.Power, 
     main = "Boxplot of Compute Power", 
     xlab = "Compute Power", 
     col = "lightgreen", 
     border = "black")

boxplot(llm_data$Efficiency, 
     main = "Boxplot of Energy Efficiency", 
     xlab = "Energy Efficiency", 
     col = "lightgreen", 
     border = "black")
dev.off()

# ---------- [Vẽ đồ thị Box Plot theo Provider] ---------- #
png("output/figures/boxplots_provider.png", width = 1280, height = 720)
par(mfrow = c(2, 3))

boxplot(`Speed` ~ Provider, data = llm_data,
        main = "Speed (tokens/sec) by Provider",
        xlab = "Speed (tokens/sec)",
        col = "lightgreen")
boxplot(`Latency` ~ Provider, data = llm_data,
        main = "Latency (sec) by Provider",
        xlab = "Latency (sec)",
        col = "lightgreen")
boxplot(`Price` ~ Provider, data = llm_data,
        main = "Price / Million Tokens by Model",
        xlab = "Price / Million Tokens",
        col = "lightgreen")
boxplot(`Dataset.Size` ~ Provider, data = llm_data,
        main = "Training Dataset Size by Provider",
        xlab = "Training Dataset Size",
        col = "lightgreen")
boxplot(`Compute.Power` ~ Provider, data = llm_data,
        main = "Compute Power by Provider",
        xlab = "Compute Power",
        col = "lightgreen")
boxplot(`Efficiency` ~ Provider, data = llm_data,
        main = "Energy Efficiency by Model",
        xlab = "Energy Efficiency",
        col = "lightgreen")
dev.off()

# ---------- [Kiểm tra phân phối chuẩn] ---------- #
png("output/figures/qq_plot.png", width = 1280, height = 720)
par(mfrow = c(2, 3))
qqnorm(llm_data$Speed, main = "Q-Q Plot of Speed")
qqline(llm_data$Speed, col = "red")
qqnorm(llm_data$Latency, main = "Q-Q Plot of Latency")
qqline(llm_data$Latency, col = "red")
qqnorm(llm_data$Price, main = "Q-Q Plot of Price")
qqline(llm_data$Price, col = "red")
qqnorm(llm_data$Dataset.Size, main = "Q-Q Plot of Dataset.Size")
qqline(llm_data$Dataset.Size, col = "red")
qqnorm(llm_data$Compute.Power, main = "Q-Q Plot of Compute.Power")
qqline(llm_data$Compute.Power, col = "red")
qqnorm(llm_data$Efficiency, main = "Q-Q Plot of Efficiency")
qqline(llm_data$Efficiency, col = "red")
dev.off()

# ---------- [Biểu đồ tương quan] ---------- #
library(corrplot)

# 2. Chọn các biến số (numeric)
numeric_vars <- llm_data[, sapply(llm_data, is.numeric)]

# 3. Tính ma trận tương quan
cor_matrix <- cor(numeric_vars, use = "complete.obs", method = "pearson")

# 4. Vẽ biểu đồ tương quan đối xứng hình vuông
png("output/figures/corrplot.png", width = 1280, height = 720)
par(mfrow = c(1, 1))
corrplot(cor_matrix,
         method = "color",     # Hình vuông
         type = "full",         # Hiện cả tam giác trên và dưới
         tl.col = "black",      # Màu chữ
         tl.srt = 45,           # Góc xoay nhãn
         addCoef.col = "red", # Hiện hệ số tương quan
         number.cex = 0.7)

dev.off()

# ---------- [Kiểm định một mẫu phân phối chuẩn] ---------- #
# Kiểm định Shapiro
shapiro.test(llm_data$Speed)
shapiro.test(llm_data$Latency)
shapiro.test(llm_data$Price)
shapiro.test(llm_data$Dataset.Size)
shapiro.test(llm_data$Compute.Power)
shapiro.test(llm_data$Efficiency)
# Toàn bộ không tuân theo phân phối chuẩn vì p << 0.05

# Tìm khoảng ước lượng
t.test(llm_data$Speed, conf.level = 0.95)
t.test(llm_data$Latency, conf.level = 0.95)
t.test(llm_data$Price, conf.level = 0.95)
t.test(llm_data$Dataset.Size, conf.level = 0.95)
t.test(llm_data$Compute.Power, conf.level = 0.95)
t.test(llm_data$Efficiency, conf.level = 0.95)

# ---------- [Kiểm định hai mẫu phân phối chuẩn] ---------- #
# Tính giá trị trung bình
mean_latency <- mean(llm_data$Latency)
mean_dataset <- mean(llm_data$Dataset.Size)

# Tổng số mẫu
total <- nrow(llm_data)

# Tính tỷ lệ 1: Latency > mean(Latency) và Speed > mean(Speed)
cond_latency_high <- subset(llm_data, Latency > mean_latency & Dataset.Size > mean_dataset)
num_latency_high <- nrow(cond_latency_high)
ratio_latency_high <- num_latency_high / total

# Tính tỷ lệ 2: Latency < mean(Latency) và Speed > mean(Speed)
cond_latency_low <- subset(llm_data, Latency < mean_latency & Dataset.Size > mean_dataset)
num_latency_low <- nrow(cond_latency_low)
ratio_latency_low <- num_latency_low / total

# In kết quả
cat("Tỷ lệ Latency > mean và Speed > mean: ", round(ratio_latency_high * 100, 2), "%\n")
cat("Tỷ lệ Latency < mean và Speed > mean: ", round(ratio_latency_low * 100, 2), "%\n")
prop_result <- prop.test(c(num_latency_high, num_latency_low), c(total, total),
                         alternative = "less", correct = FALSE)
prop_result
# --------------------------------------------------------------------- #


# Lọc dữ liệu có đầy đủ thông tin
latency_data <- llm_data[!is.na(llm_data$Latency) & !is.na(llm_data$Provider), ]

# ANOVA
anova_latency <- aov(Latency..sec. ~ Provider, data = latency_data)
summary(anova_latency)

# Kiểm định giả thuyết:
  # H0: Độ trễ trung bình giữa các nhà cung cấp là như nhau
  # H1: Có ít nhất một nhà cung cấp có độ trễ trung bình khác biệt
# Nếu p-value < 0.05 → Bác bỏ H0 → Có sự khác biệt có ý nghĩa

# Kết quả: 0.05 < p < 0.1: "Có xu hướng khác biệt về độ trễ giữa các nhà cung cấp, nhưng chưa đủ mạnh để kết luận một cách chắc chắn ở mức ý nghĩa 5%."

model1 <- lm(Latency..sec. ~ Provider, data = llm_data)
summary(model1)

boxplot(Latency ~ Provider, data = llm_data,
        col = "lightgreen", main = "Latency theo từng Provider")

ggplot(llm_data, aes(x = Speed..tokens.sec., y = Latency, color = Provider)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Hồi quy Latency ~ Speed theo từng Provider",
       x = "Speed (tokens/sec)",
       y = "Latency")

anova2 <- aov(Latency..sec. ~ Provider + Speed..tokens.sec. + Compute.Power, data = llm_data)
summary(anova2)





