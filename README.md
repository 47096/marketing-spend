# Where should the next marketing dollar go?

**A budget problem, solved with channel data.**

Marketing spend is not one pot — it is **YouTube, Facebook, newspaper, and a board that wants returns**. I help teams see **which channel actually pays** so budget follows evidence, not habit.

---

## The stake

If you spread spend evenly, you subsidise the weak channel. If you only trust last-click, you underfund discovery. The expensive mistake is **paying for media that does not move sales**.

## The story

You have spend and sales by channel. Two honest questions:

1. Does **total marketing spend** even predict sales?  
2. If we split it, **which channel earns its keep**?

I built both: a simple spend→sales model, then a per-channel model. Same data. Different decisions.

**Outcome on this build:**
- Total spend explains a lot of sales movement (**R² ≈ 0.75**)  
- **Per-channel is much sharper (R² ≈ 0.90+)** — you can act on it  
- **Facebook had the highest per-dollar return** in this dataset  
- **Newspaper showed no reliable effect** — candidate to cut or test harder  

> **The commercial idea:** stop asking “are we spending enough?” Ask **“which dollar works?”**

---

## What that looks like in your world

| You have | I turn it into |
|----------|----------------|
| Channel spend + revenue exports | **Per-channel contribution** |
| “We always put X% in this channel” | Evidence to **reallocate** |
| Agency reports full of impressions | **Sales-linked** read on efficiency |
| A budget fight next week | A simple **spend vs return** view |

**Typical engagement:** connect spend and outcome data → model contribution → recommend a test/reallocate plan (not a black-box “AI budget tool”).

**[Talk to me about marketing spend →](https://datafying.co/#contactus)** · [datafying](https://datafying.co/)

---

## Why marketing leaders bring me in

- Starts from **budget language**, not regression jargon  
- Compares **simple vs richer models** so you see what more detail buys  
- Flags channels that **don’t earn their keep**  
- Honest about limits: correlation ≠ full causality without a test design  

---

## Proof of craft *(technical)*

### Job
Regress `sales` on advertising spend — simple (total) vs multiple (per channel).

### Two models on one dataset

| Script | Approach | Features | R² |
|--------|----------|----------|-----|
| `01-total-spend.R` | Base R `lm()` | total spend | **0.753** |
| `02-per-channel.R` | tidymodels `linear_reg()` | youtube, facebook, newspaper | **0.901** (test ~0.925) |

### Simple model
```
predicted_sales = 5.09 + 0.049 × total_spend
```
RMSE 3.10 · MAE 2.34 — useful baseline.

### Per-channel model

| Channel | Coefficient | p-value | Read as |
|---------|-------------|---------|---------|
| Facebook | 0.190 | ≈ 0 | Highest **per-dollar** return in this data |
| YouTube | 0.046 | ≈ 0 | Real effect, weaker per dollar |
| Newspaper | 0.005 | 0.418 | **Not significant** — don’t trust the point estimate |

**So what for a budget holder:** RMSE fell **3.10 → 1.74** when channels were separated. That is the difference between “spend more” and “spend differently.”

### Limits (honesty)
- Observational data — **not** a media experiment; run a holdout/geo test before a hard reallocation  
- No adstock / saturation (not full MMM)  
- Linearity and market regime can shift; refresh on a cadence  

---

## Reproduce

```bash
git clone https://github.com/47096/marketing-spend.git
cd marketing-spend
```

```r
source("setup.R")
source("01-total-spend.R")
source("02-per-channel.R")
```

**Stack:** R · `tidyverse` · `tidymodels` · `Metrics` · `broom` · `vip`

---

## Next step

If the budget meeting is coming up and the channel debate is vibes-based — that is the engagement I run.

**[Book a conversation →](https://datafying.co/#contactus)** · Customer & marketing analytics · [datafying](https://datafying.co/)
