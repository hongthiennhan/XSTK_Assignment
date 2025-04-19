llm_comparison <- read.csv("D:/HCMUT/XSTK/XSTK_Assignment/data/llm_comparison_dataset.csv")
str(llm_comparison)

missing_data_summary <- sapply(llm_comparison, function(x) {
  total_missing <- sum(is.na(x))
  percent_missing <- (total_missing / length(x)) * 100
  return(c(Total_missing = total_missing, Percent_missing = percent_missing))
})
as.data.frame(t(missing_data_summary))

library(psych)
describe(llm_comparison)

library(dplyr)
library(purrr)

# Chọn tất cả biến phân loại (kiểu character hoặc factor)
categorical_vars <- llm_comparison %>%
  select(where(~ is.character(.) | is.factor(.)))

# In bảng tần số cho từng biến
walk2(categorical_vars, names(categorical_vars), ~ {
  cat("\n====", .y, "====\n")
  print(table(.x))
})

par(mfrow = c(1, 3))  # Gộp 3 biểu đồ theo hàng ngang

hist(llm_comparison$Latency..sec., main = "Latency", col = "lightblue")
hist(llm_comparison$Price...Million.Tokens, main = "Price", col = "lightblue")
hist(llm_comparison$Energy.Efficiency, main = "Energy Efficiency", col = "lightblue")

par(mfrow = c(1, 1))  # Reset lại sau khi vẽ xong

par(mfrow = c(1, 3))

boxplot(`Latency..sec.` ~ Provider, data = llm_comparison,
        main = "Latency by Provider", col = "lightgreen")
boxplot(`Price...Million.Tokens` ~ Provider, data = llm_comparison,
        main = "Price by Provider", col = "lightgreen")
boxplot(`Energy.Efficiency` ~ Provider, data = llm_comparison,
        main = "Efficiency by Provider", col = "lightgreen")

par(mfrow = c(1, 1))
