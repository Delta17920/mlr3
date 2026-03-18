library(changepoint)
library(binsegRcpp)
library(ggplot2)

# Dataset 1 - subtle gradual shifts
set.seed(42)
data1 <- c(
  rnorm(120, mean = 0,   sd = 2),
  rnorm(130, mean = 1.5, sd = 2),
  rnorm(90,  mean = 0.5, sd = 2),
  rnorm(160, mean = 3,   sd = 2)
)

# Dataset 2 - mixed strong and weak shifts
set.seed(99)
data2 <- c(
  rnorm(100, mean = 0,   sd = 1),
  rnorm(80,  mean = 3,   sd = 1),
  rnorm(60,  mean = 3.5, sd = 1),
  rnorm(120, mean = 0,   sd = 1),
  rnorm(140, mean = 5,   sd = 1)
)

# Run PELT on both datasets
pelt1 <- cpt.mean(data1, method = "PELT")
pelt2 <- cpt.mean(data2, method = "PELT")

# Run BinSeg on both datasets
binseg1 <- binseg("mean_norm", data1, max.segments = 4)
binseg2 <- binseg("mean_norm", data2, max.segments = 5)

# Get breakpoints - explicitly remove end-of-series marker
pelt1_breaks   <- cpts(pelt1)
pelt2_breaks   <- cpts(pelt2)

binseg1_splits <- binseg1$splits$end
binseg1_breaks <- sort(binseg1_splits[binseg1_splits < 500][1:3])

binseg2_splits <- binseg2$splits$end
binseg2_breaks <- sort(binseg2_splits[binseg2_splits < 500][1:4])

cat("Dataset 1 - PELT breakpoints:", pelt1_breaks, "\n")
cat("Dataset 1 - BinSeg breakpoints:", binseg1_breaks, "\n")
cat("Dataset 2 - PELT breakpoints:", pelt2_breaks, "\n")
cat("Dataset 2 - BinSeg breakpoints:", binseg2_breaks, "\n")

# Build data frames
df1 <- data.frame(x = 1:500, y = data1, dataset = "Dataset 1 (Gradual Shifts)")
df2 <- data.frame(x = 1:500, y = data2, dataset = "Dataset 2 (Mixed Shifts)")
df  <- rbind(df1, df2)

# Build breakpoints data frame
bpts_df <- rbind(
  data.frame(x = pelt1_breaks,   dataset = "Dataset 1 (Gradual Shifts)", algo = "PELT"),
  data.frame(x = pelt2_breaks,   dataset = "Dataset 2 (Mixed Shifts)",   algo = "PELT"),
  data.frame(x = binseg1_breaks, dataset = "Dataset 1 (Gradual Shifts)", algo = "BinSeg"),
  data.frame(x = binseg2_breaks, dataset = "Dataset 2 (Mixed Shifts)",   algo = "BinSeg")
)

# Plot
ggplot(df, aes(x = x, y = y)) +
  geom_line(color = "steelblue", linewidth = 0.6) +
  geom_vline(data = bpts_df,
             aes(xintercept = x, color = algo, linetype = algo),
             linewidth = 1) +
  scale_color_manual(values = c("PELT" = "#E63946", "BinSeg" = "#2A9D8F")) +
  scale_linetype_manual(values = c("PELT" = "dashed", "BinSeg" = "dotted")) +
  facet_wrap(~ dataset, ncol = 1, scales = "free_y") +
  labs(
    title    = "Medium Test: PELT vs BinSeg on Two Datasets",
    subtitle = "Red dashed = PELT  |  Green dotted = BinSeg",
    x        = "Time Index",
    y        = "Value",
    color    = "Algorithm",
    linetype = "Algorithm"
  ) +
  theme_bw(base_size = 13) +
  theme(legend.position = "top")