

# Get consistent bins to compare histograms from columns in a datafram
import numpy as np

data = pd.DataFrame(all_rows, columns=["name", "quality_score"])

# calculate shared bins
bins = np.histogram(np.hstack(data["quality_score"]), bins=10)[1]

series = data.groupby("name").quality_score.apply(list)

for name, values in series.items():
    print(name)
    hist = np.histogram(values, bins=bins)
    for count, left_bin_edge in sorted(
        zip(*hist), key=lambda pair: pair[-1], reverse=True
    ):
        print(f"{left_bin_edge}: {count}")

# output:
    LC12
    0.06371014164857912: 1
    0.05663128141508196: 0
    0.04955242118158481: 0
    0.04247356094808766: 0
    0.0353947007145905: 0
    0.028315840481093348: 1
    0.021236980247596196: 3
    0.014158120014099041: 3
    0.007079259780601888: 10
    3.995471047346655e-07: 24155
    LC12.initialrun
    0.06371014164857912: 1
    0.05663128141508196: 0
    0.04955242118158481: 0
    0.04247356094808766: 0
    0.0353947007145905: 0
    0.028315840481093348: 1
    0.021236980247596196: 3
    0.014158120014099041: 3
    0.007079259780601888: 9
    3.995471047346655e-07: 27052
