# Sales Forecasting with Time Series Analysis — Project Report

## 1. Time Series Analysis

**Data.** 730 days (2 years) of daily `sales_units`, synthetically generated with an upward trend, a 7-day weekly seasonal cycle, a secondary 365-day yearly cycle, and Gaussian noise — designed to resemble realistic retail sales behavior rather than a random walk.

**Decomposition.** Additive seasonal decomposition (7-day period) confirmed all three expected components: a steady upward trend across the two years, a clear repeating weekly seasonal pattern, and residual noise with no obvious remaining structure.

**Stationarity.** An Augmented Dickey-Fuller test on the raw series returned an ADF statistic of -0.481 (p-value 0.896), confirming the series is **non-stationary** — expected, given the built-in trend and seasonality. This directly motivated using SARIMA (which differences internally, order `(1,1,1)`, seasonal order `(1,1,1,7)`) and Exponential Smoothing (which models trend and seasonality explicitly) rather than a naive model that assumes stationarity.

## 2. Modeling Approach

Four forecasting approaches were implemented and compared on a strict time-based 80/20-style split (last 28 days held out as test, no shuffling — critical for valid time series evaluation):

1. **Moving Average** (7-day window, walk-forward) — simple baseline.
2. **Exponential Smoothing** (Holt-Winters, additive trend + additive weekly seasonality).
3. **SARIMA** — order (1,1,1), seasonal order (1,1,1,7), providing native 95% confidence intervals.
4. **Random Forest on lagged features** (7 lag features, ML-based alternative approach).

## 3. Results

| Model | MAE | RMSE | MAPE |
|---|---|---|---|
| Moving Average | 10.157 | 11.496 | 8.79% |
| **Exponential Smoothing** | **4.253** | **5.101** | **3.69%** |
| SARIMA | 4.933 | 6.322 | 4.26% |
| Random Forest (lagged) | 6.861 | 8.306 | 5.84% |

**Best model: Exponential Smoothing**, with the lowest error across all three metrics (MAE 4.25, RMSE 5.10, MAPE 3.69%). This is a sensible outcome — Holt-Winters is purpose-built for series with a clear additive trend and fixed seasonal period, which matches exactly how this dataset was constructed. SARIMA performed close behind (MAPE 4.26%), which is expected since it explicitly handles the same trend/seasonality structure via differencing and seasonal terms. The Moving Average baseline, as expected, performed clearly worst (MAPE 8.79%) since it has no mechanism to capture trend or seasonality — its role here is purely as a sanity-check floor. The Random Forest on lagged features sat between the classical models and the baseline (MAPE 5.84%): a reasonable result, but tree-based models with a small, fixed lag window are inherently less suited to periodic structure than Holt-Winters/SARIMA, which model seasonality directly.

Unlike Tasks 1-4, none of these results are artificially perfect — errors are realistic and differentiated across models, which strengthens confidence that this evaluation reflects genuine forecasting skill rather than a synthetic-data artifact.

## 4. Forecast — Next 4 Weeks (with confidence intervals)

Using SARIMA fit on the full 730-day history, the model forecasts daily sales for the next 28 days (Dec 31, 2024 – Jan 27, 2025), with the weekly seasonal cycle clearly visible in the predictions (values oscillate roughly between ~103 and ~132 units, repeating on a 7-day rhythm consistent with the historical pattern):

| Date | Forecast (units) |
|---|---|
| 2024-12-31 | 130.4 |
| 2025-01-01 | 123.3 |
| 2025-01-02 | 111.3 |
| 2025-01-03 | 102.5 |
| 2025-01-04 | 104.7 |
| 2025-01-05 | 117.6 |
| 2025-01-06 | 128.9 |
| ... | *(repeats weekly pattern through 2025-01-27)* |
| 2025-01-27 | 130.9 |

95% confidence intervals for each forecasted day are computed by the SARIMA model (`get_forecast().conf_int()`) and plotted alongside the point forecast in `report/forecast_vs_actual.png`, widening appropriately further into the forecast horizon — reflecting increasing uncertainty the further out the prediction extends.

## 5. Challenges

- **Non-stationarity** required explicit handling (SARIMA differencing, Exponential Smoothing's trend/seasonal decomposition) rather than naive modeling — confirmed via the ADF test before model selection.
- **Model selection trade-off**: while SARIMA is the more theoretically rigorous choice (native confidence intervals, explicit statistical structure), Exponential Smoothing outperformed it slightly on this dataset — a reminder that simpler models can beat more complex ones when their assumptions match the data well.
- **Lag-based ML approach's ceiling**: Random Forest with only lag features lacks an explicit seasonal mechanism, which likely explains its weaker performance relative to the classical time series models on this clearly seasonal dataset.

## 6. Potential Improvements

- Extend evaluation with time series cross-validation (rolling-origin, e.g. `sklearn.model_selection.TimeSeriesSplit`) rather than a single train/test split, for a more robust performance estimate.
- Add calendar-based and holiday features to the Random Forest approach (day-of-week, month, holiday flags) to give it comparable seasonal signal to SARIMA/Exponential Smoothing.
- Try Prophet or a gradient-boosted time series model (e.g. LightGBM with engineered seasonal features) as an additional comparison point.
- Validate against real historical sales data, since the synthetic data's seasonality is clean and consistent — real sales are typically noisier and may include irregular effects (promotions, holidays, stockouts) not present here.