library(changepoint)

# Simulate a signal with 3 change-points
set.seed(42)
signal <- c(
  rnorm(120, mean = 0, sd = 1),
  rnorm(130, mean = 5, sd = 1),
  rnorm(90,  mean = 2, sd = 0.5),
  rnorm(160, mean = 8, sd = 1.5)
)

# Run PELT change-point detection
cpt_result <- cpt.mean(signal, method = "PELT")

# Print detected change-points
cat("Change-points detected at positions:", cpts(cpt_result), "\n")

# Plot
plot(cpt_result,
     main = "Easy Test: Change-Point Detection using PELT",
     xlab = "Time Index",
     ylab = "Value",
     col  = "steelblue",
     cpt.col = "red",
     cpt.width = 3)
