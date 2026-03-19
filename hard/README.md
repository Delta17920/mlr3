# Hard Test - IntervalRegressionCV on neuroblastomaProcessed

## Objective
Run `penaltyLearning::IntervalRegressionCV` on the neuroblastoma dataset, code a train/test split, and compute test accuracy and ROC curves.

## Dataset
`neuroblastomaProcessed` from the `penaltyLearning` package - the official pre-processed version of the neuroblastoma dataset with:
- **3418** labeled segmentation problems (profile × chromosome pairs)
- **117** features per problem (signal statistics, RSS, MSE, chromosome indicators)
- **2 target columns**: min and max log(penalty) intervals for weakly supervised learning

## Train/Test Split
- 80% train: **2734 rows**
- 20% test: **684 rows**
- Split on row indices with `set.seed(42)` for reproducibility

## Model
`IntervalRegressionCV` from the `penaltyLearning` package:
- L1-regularized linear interval regression
- 5-fold cross-validation to select regularization parameter
- `incorrect.labels.db` argument used for AUC-based CV model selection (the correct approach per package documentation)
- Trained on all 117 features

## Results
| Metric | Value |
|--------|-------|
| **Test Accuracy** | 97.66% |
| **AUC** | 0.9931 |

- A prediction is considered correct if the predicted log(penalty) falls within the target interval `[min.log.lambda, max.log.lambda]`
- ROC curve computed using `ROChange` from `penaltyLearning` - the proper method designed for this type of weakly supervised problem

## Observations
- An AUC of 0.9931 indicates the model almost perfectly ranks segmentation problems by their optimal penalty
- The ROC curve rises steeply to TPR ≈ 1.0 with near-zero FPR, confirming excellent discrimination
- Both the min.error and predicted thresholds sit at the top-left corner of the ROC curve - the ideal position
- Using all 117 pre-computed features from `neuroblastomaProcessed` instead of hand-crafted features is key to achieving this performance

## Files
| File | Description |
|------|-------------|
| `hard_test.R` | R script to run the full analysis |
| `output/hard_test_roc.png` | ROC curve plot with AUC |
| `output/hard_test_output.png` | Screenshot of console output showing accuracy and AUC |

## How to Run
```r
install.packages(c("penaltyLearning", "ROCR", "ggplot2", "data.table"))
source("hard_test.R")
```

## ROC Curve
![ROC Curve](output/hard_test_roc.png)

## Console Output
![Console Output](output/hard_test_output.png)
