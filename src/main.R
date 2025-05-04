# INSTALL PACKAGE
# install.packages("tidyr")
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("statip")
# install.packages("ggplot2")
# install.packages("grid")
# install.packages("gridBase")
# install.packages("corrplot")
# install.packages("ggpubr")
# install.packages("zoo")
# install.packages("car")

# ---------------------------
# Includes
library(tidyr)
library(stringr)
library(dplyr)
library(statip)
library(ggplot2)
library(grid)
library(gridBase)
library(corrplot)
library(ggpubr)
library(zoo)
library(car)


# ---------- [Đọc thông tin dữ liệu] ---------- #
# Đọc dữ liệu từ file CSV
llm_data <- read.csv("../data/llm_comparison_dataset.csv")

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
summary_df <- data.frame(lapply(summary_df, function(x) formatC(x, format = "f", digits = 4, drop0trailing = TRUE)))
print(summary_df)
table(llm_data$Provider)
table(llm_data$Provider)

# ---------- [Vẽ đồ thị Histogram] ---------- #
png("../output/figures/histograms.png", width = 1280, height = 720)
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
png("../output/figures/boxplots.png", width = 1280, height = 720)
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
png("../output/figures/boxplots_provider.png", width = 1280, height = 720)
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
        main = "Price / Million Tokens by Provider",
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
        main = "Energy Efficiency by Provider",
        xlab = "Energy Efficiency",
        col = "lightgreen")
dev.off()

# ---------- [Kiểm tra phân phối chuẩn] ---------- #
png("../output/figures/qq_plot.png", width = 720, height = 1280)
par(mfrow = c(3, 2))
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
png("../output/figures/corrplot.png", width = 1280, height = 1280)
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
par(mfrow = c(1, 1))
qqnorm(llm_data$Latency, main = "Q-Q Plot of Latency")
qqline(llm_data$Latency, col = "red")

# Kiểm định Shapiro
# shapiro.test(llm_data$Speed)
shapiro.test(llm_data$Latency)
# shapiro.test(llm_data$Price)
# shapiro.test(llm_data$Dataset.Size)
# shapiro.test(llm_data$Compute.Power)
# shapiro.test(llm_data$Efficiency)

# Không tuân theo phân phối chuẩn vì p << 0.05

# Tìm khoảng ước lượng
# t.test(llm_data$Speed, conf.level = 0.95)
t.test(llm_data$Latency, conf.level = 0.95)
# t.test(llm_data$Price, conf.level = 0.95)
# t.test(llm_data$Dataset.Size, conf.level = 0.95)
# t.test(llm_data$Compute.Power, conf.level = 0.95)
# t.test(llm_data$Efficiency, conf.level = 0.95)

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

# ---------- [Phân tích phương sai] ---------- #
table(llm_data$Provider)
# Xử lý mẫu
llm_data_filtered <- subset(llm_data, Provider %in% names(table(llm_data$Provider)[table(llm_data$Provider) >= 20]))
table(llm_data_filtered$Provider)

# Kiểm tra phân phối chuẩn
provider_1 <- subset(llm_data_filtered, Provider == "AWS")
provider_2 <- subset(llm_data_filtered, Provider == "Cohere")
provider_3 <- subset(llm_data_filtered, Provider == "Deepseek")
provider_4 <- subset(llm_data_filtered, Provider == "Google")
provider_5 <- subset(llm_data_filtered, Provider == "Meta AI")
provider_6 <- subset(llm_data_filtered, Provider == "Mistral AI")
provider_7 <- subset(llm_data_filtered, Provider == "OpenAI")
shapiro.test(provider_1$Efficiency)
shapiro.test(provider_2$Efficiency)
shapiro.test(provider_3$Efficiency)
shapiro.test(provider_4$Efficiency)
shapiro.test(provider_5$Efficiency)
shapiro.test(provider_6$Efficiency)
shapiro.test(provider_7$Efficiency)

# Đánh giá tính đồng nhất phương sai
library(car)
leveneTest(Efficiency ~ as.factor(Provider), llm_data_filtered)

# ANOVA
anova_efficiency <- aov(Efficiency ~ Provider, data = llm_data_filtered)
summary(anova_efficiency)

TukeyHSD(anova_efficiency)
frame()
plot.new()
pushViewport(viewport(layout = grid.layout(1, 1)))
par(fig = c(0.15, 0.95, 0, 1), new = TRUE)
plot(TukeyHSD(anova_efficiency), las = 1)

# ----------------- Hồi quy tuyến tính ----------------------#
model <- lm(formula(llm_data$Benchmark.MMLU ~ llm_data$Context.Window + llm_data$Latency + llm_data$Speed + llm_data$Benchmark.Chatbot.Arena. + llm_data$Open.Source + llm_data$Price + llm_data$Compute.Power + llm_data$Efficiency + llm_data$Quality.Rating + llm_data$Speed.Rating + llm_data$Price.Rating))
summary(model)
model_new <- lm(formula(llm_data$Benchmark.MMLU ~ llm_data$Quality.Rating + llm_data$Speed.Rating + llm_data$Speed + llm_data$Price.Rating))
summary(model_new)
confint(model_new, level = 0.95)
par(mfrow = c(2, 2))
plot(model_new)

vif(model_new)
vif_value <- vif(model_new)
vp0 <- viewport(x = .15, y = 0, just = c("left", "bottom"), width = 0.85, height = 1)
pushViewport(vp0)

plot.new()
par(mfrow = c(1, 1))
par(new = TRUE, fig = gridFIG())
par(mar = c(5, 4, 1, 2))
barplot(vif_value, main = "VIF Values", horiz = TRUE, col = "steelblue",
           xlim = c(0,5), las = 2, names.arg = c("Quality.Rating","Speed.Rating", "Speed", "Price.Rating"))
abline(v = 5, lwd = 5, lty = 2)

# df <- summary_stat %>%
#   count_and_ratio_outliers(Quality.Rating) %>%
#   count_and_ratio_outliers(Speed.Rating) %>%
#   subset(select = -c(
#     Context.Window,
#     Latency,
#     Speed,
#     Benchmark.Chatbot.Arena.,
#     Open.Source,
#     Price,
#     Compute.Power,
#     Efficiency,
#     Price.Rating
#   ))
# --------------------------------------------------------------------- #

# ----------------- Dự đoán trên mô hình hồi quy tuyến tính ----------------------#
set.seed(123)  # Đặt seed để kết quả có thể tái lập

train_index <- sample(seq_len(nrow(llm_data)), size = 0.99 * nrow(llm_data))

# Tạo tập huấn luyện và kiểm tra
df_train <- llm_data[train_index, ]
df_test <- llm_data[-train_index, ]

x_test <- llm_data[-train_index, !(names(llm_data) %in% "Benchmark.MMLU")]
y_test <- llm_data[-train_index, "Benchmark.MMLU"]

model_predict <- lm(Benchmark.MMLU ~ Quality.Rating + Speed.Rating + Speed + Price.Rating, data = df_train)
predictions <- predict(model_predict, newdata = df_test)

anova(model_predict) %>% print()
summary(model_predict) %>% print()
y_pred <- predict(model_predict, newdata = x_test, interval = "confidence")
mse <- mean((y_test - y_pred)^2)
mae <- mean(abs(y_test - y_pred))
rmse <- sqrt(mse)
# Calculate R-squared
rss <- sum((y_test - y_pred)^2)
tss <- sum((y_test - mean(y_test))^2)
r_squared <- 1 - (rss / tss)
data.frame(mse, mae, rmse, r_squared) %>% print()



# actuals <- df_test$Benchmark.MMLU
# plot.new()
# par(mfrow = c(1, 1))
# plot(actuals, predictions,
#      xlab = "Giá trị thực tế (Actual Benchmark.MMLU)",
#      ylab = "Giá trị dự đoán (Predicted)",
#      main = "So sánh Dự đoán vs Thực tế",
#      col = "blue", pch = 16)
# abline(0, 1, col = "red", lwd = 2)  # Đường y = x

# ----------------- Phần thảo luận và mở rộng ----------------------#






# --------------------------------------------------------------------- #
# ANOVA and Linear Models with log(Latency)

# --- Model 1: log(Latency) ~ Provider ---
# ANOVA
anova_log_latency_provider <- aov(log(Latency) ~ Provider, data = llm_data) # Use llm_data and log(Latency)
summary(anova_log_latency_provider)

# Linear Model
model1_log <- lm(log(Latency) ~ Provider, data = llm_data) # Use log(Latency)
summary(model1_log)

# Boxplot for log(Latency)
boxplot(log(Latency) ~ Provider, data = llm_data,
        col = "lightgreen", main = "log(Latency) theo từng Provider",
        ylab = "log(Latency)")

# --- Model 2: log(Latency) ~ Provider * Speed + Other Predictors ---

# Scatter plot with log(Latency)
ggplot(llm_data, aes(x = Speed, y = log(Latency), color = Provider)) + # Use log(Latency)
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Hồi quy log(Latency) ~ Speed theo từng Provider",
       x = "Speed (tokens/sec)",
       y = "log(Latency)")

# More comprehensive ANOVA model
# Including interaction and other potentially relevant variables
anova_log_complex <- aov(log(Latency) ~ Provider * Speed + Compute.Power + Context.Window + Price + Dataset.Size + Efficiency, data = llm_data)
summary(anova_log_complex)

# Check assumptions for the complex model
png("../output/figures/anova_log_complex_plots.png", width = 1000, height = 1000) # Open PNG device
par(mfrow = c(2, 2)) # Set 2x2 plot layout
plot(anova_log_complex)
dev.off()

par(mfrow = c(1, 1))





