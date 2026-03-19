library(penaltyLearning)
library(ggplot2)
library(data.table)
library(survival)

# Load pre-processed data
data("neuroblastomaProcessed", package = "penaltyLearning", envir = environment())

feature.mat <- neuroblastomaProcessed$feature.mat
target.mat  <- neuroblastomaProcessed$target.mat
errors.dt   <- as.data.table(neuroblastomaProcessed$errors)
errors.dt[, pid.chr := paste0(profile.id, ".", chromosome)]
setkey(errors.dt, pid.chr)

n.obs <- nrow(feature.mat)
cat("Total observations:", n.obs, "\n")
cat("Total features:", ncol(feature.mat), "\n")

# K-fold CV on labeled sequences
set.seed(1)
n.folds <- 5
fold.vec <- sample(rep(1:n.folds, length.out = n.obs))

model.colors <- c(
  "constant"             = "black",
  "BIC/SIC"              = "#1B9E77",
  "IntervalRegressionCV" = "#7570B3"
)

cv.roc.list <- list()
cv.auc.list <- list()

for(test.fold in 1:n.folds){
  cat("Processing fold", test.fold, "\n")
  
  i.train <- which(fold.vec != test.fold)
  i.test  <- which(fold.vec == test.fold)
  
  train.feature.mat <- feature.mat[i.train, ]
  train.target.mat  <- target.mat[i.train, ]
  test.feature.mat  <- feature.mat[i.test, ]
  test.target.mat   <- target.mat[i.test, ]
  
  # 1. IntervalRegressionCV
  set.seed(1)
  fit.cv <- IntervalRegressionCV(
    feature.mat         = train.feature.mat,
    target.mat          = train.target.mat,
    incorrect.labels.db = errors.dt,
    verbose             = 0
  )
  pred.cv <- as.numeric(fit.cv$predict(test.feature.mat))
  
  # 2. BIC/SIC baseline — use n.loglog feature (log(log(n)))
  pred.bic <- test.feature.mat[, "log2.n"]
  
  # 3. Constant baseline — best constant on train set
  const.pen.vec <- seq(-4, 4, by = 0.1)
  const.acc.vec <- sapply(const.pen.vec, function(pen){
    sum(train.target.mat[,1] < pen & pen < train.target.mat[,2],
        na.rm = TRUE)
  })
  best.constant <- const.pen.vec[which.max(const.acc.vec)]
  pred.const <- rep(best.constant, length(i.test))
  
  # Compute accuracy for IntervalRegressionCV
  correct <- pred.cv >= test.target.mat[,1] & pred.cv <= test.target.mat[,2]
  cat(sprintf("  Fold %d CV Accuracy: %.2f%%\n", test.fold,
              mean(correct, na.rm=TRUE)*100))
  
  # ROC curves for all 3 models
  test.names <- rownames(feature.mat)[i.test]
  errors.test <- errors.dt[pid.chr %in% test.names]
  
  pred.list <- list(
    "IntervalRegressionCV" = pred.cv,
    "BIC/SIC"              = as.numeric(pred.bic),
    "constant"             = pred.const
  )
  
  for(model.name in names(pred.list)){
    pred.dt <- data.table(
      pid.chr         = test.names,
      pred.log.lambda = pred.list[[model.name]]
    )
    roc.result <- ROChange(
      models       = errors.test,
      predictions  = pred.dt,
      problem.vars = "pid.chr"
    )
    cv.roc.list[[paste(test.fold, model.name)]] <- data.table(
      test.fold, model = model.name, roc.result$roc
    )
    cv.auc.list[[paste(test.fold, model.name)]] <- data.table(
      test.fold, model = model.name, auc = roc.result$auc,
      roc.result$thresholds[threshold == "predicted"]
    )
  }
}

# Combine results
cv.roc <- rbindlist(cv.roc.list)
cv.auc <- rbindlist(cv.auc.list)

# Print AUC summary
auc.summary <- cv.auc[, .(mean.auc = round(mean(auc), 4),
                          sd.auc   = round(sd(auc), 4)),
                      by = model]
print(auc.summary)

# Plot ROC curves - all folds and models
ggplot() +
  scale_color_manual(values = model.colors) +
  geom_path(aes(
    FPR, TPR, color = model,
    group = paste(model, test.fold)),
    data = cv.roc,
    linewidth = 0.8) +
  geom_point(aes(
    FPR, TPR, color = model),
    fill  = "white",
    shape = 21,
    size  = 2,
    data  = cv.auc) +
  coord_equal(xlim = c(0, 0.5), ylim = c(0.5, 1)) +
  labs(
    title    = "Hard Test: 5-Fold CV ROC Curves",
    subtitle = "IntervalRegressionCV vs BIC/SIC vs Constant baseline",
    x        = "False Positive Rate",
    y        = "True Positive Rate",
    color    = "Model"
  ) +
  theme_bw(base_size = 13) +
  theme(legend.position = "bottom")