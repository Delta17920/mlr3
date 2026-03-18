library(penaltyLearning)
library(ROCR)
library(ggplot2)
library(data.table)

# Load pre-processed neuroblastoma dataset from penaltyLearning
data("neuroblastomaProcessed", package = "penaltyLearning", envir = environment())

feature.mat <- neuroblastomaProcessed$feature.mat
target.mat  <- neuroblastomaProcessed$target.mat
errors.dt   <- as.data.table(neuroblastomaProcessed$errors)

cat("Total observations:", nrow(feature.mat), "\n")
cat("Total features:", ncol(feature.mat), "\n")

# 80/20 train/test split
set.seed(42)
n       <- nrow(feature.mat)
i.train <- sample(1:n, size = floor(0.8 * n))
i.test  <- setdiff(1:n, i.train)

cat("Train rows:", length(i.train), "\n")
cat("Test rows:", length(i.test), "\n")

# Prepare error labels for AUC-based CV selection
errors.dt[, pid.chr := paste0(profile.id, ".", chromosome)]
setkey(errors.dt, pid.chr)

# Train model
fit <- IntervalRegressionCV(
  feature.mat         = feature.mat[i.train, ],
  target.mat          = target.mat[i.train, ],
  incorrect.labels.db = errors.dt,
  verbose             = 0
)

cat("Model trained successfully!\n")

# Predict on test set
pred.test <- fit$predict(feature.mat[i.test, ])

# Accuracy - correct if prediction falls within target interval
target.test <- target.mat[i.test, ]
correct     <- pred.test >= target.test[, 1] & pred.test <= target.test[, 2]
accuracy    <- mean(correct, na.rm = TRUE)
cat("Test Accuracy:", round(accuracy * 100, 2), "%\n")

# ROC curve using ROChange
test.rownames <- rownames(feature.mat)[i.test]
errors.test   <- errors.dt[pid.chr %in% test.rownames]

pred.dt <- data.table(
  pid.chr         = test.rownames,
  pred.log.lambda = as.numeric(pred.test)
)

roc.result <- ROChange(
  models       = errors.test,
  predictions  = pred.dt,
  problem.vars = "pid.chr"
)

cat("AUC:", round(roc.result$auc, 4), "\n")

# Plot ROC curve
ggplot(roc.result$roc, aes(x = FPR, y = TPR)) +
  geom_path(color = "#E63946", linewidth = 1.2) +
  geom_abline(linetype = "dashed", color = "gray50") +
  geom_point(aes(color = threshold),
             data = roc.result$thresholds,
             shape = 1, size = 4) +
  annotate("text", x = 0.6, y = 0.2,
           label = paste0("AUC = ", round(roc.result$auc, 4)),
           size = 5, color = "#E63946") +
  labs(
    title    = "Hard Test: ROC Curve - IntervalRegressionCV on neuroblastomaProcessed",
    subtitle = "Train/test split: 80/20 | AUC-based CV | 117 features",
    x        = "False Positive Rate",
    y        = "True Positive Rate"
  ) +
  theme_bw(base_size = 13)