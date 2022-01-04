#!/usr/bin/env python3

import matplotlib.pyplot as plt

# Current latest
r'''
# ~/.config/matplotlib/matplotlibrc
text.color: DCDCDC
axes.facecolor:     0.2, 0.2, 0.2   # axes background color
axes.edgecolor:     DCDCDC   # axes edge color
axes.grid.axis:     both    # which axis the grid should apply to
axes.titlecolor:    DCDCDC    # color of the axes title, auto falls back to
axes.labelcolor:    DCDCDC
axes.prop_cycle: cycler(linestyle=['-','-.',':']) * cycler(marker=[',','x','o']) * cycler(color=['DC143C','7FFFD4','FFA500','EEE8AA','556B2F','4169E1','E6E6FA','EE82EE','7CFC00','8B008B'])
xtick.color:         DCDCDC   # color of the ticks
ytick.color:         DCDCDC   # color of the ticks
grid.color:     C0C0C0  # grid color
grid.alpha:     0.2     # transparency, between 0.0 and 1.0
legend.framealpha:    1.0      # legend patch transparency
legend.fontsize:      small
figure.facecolor:   0.2, 0.2, 0.2     # figure face color
figure.edgecolor:   0.2, 0.2, 0.2     # figure edge color
'''

# Var
NROWS = NCOLS = 3
LINES_PER_PLOT = 10

# Plot all colors
fig = plt.figure(1)
fig.suptitle('Big title')
x = [0, 1]
ax = fig.add_subplot(1, 1, 1)
for ii in range(NROWS * NCOLS * LINES_PER_PLOT):
    y = [ii + 1] * 2

    spec = {}
    if ii < 3*LINES_PER_PLOT:
        spec['label'] = f'line {ii + 1}'
    _ = ax.plot(x, y, **spec)

ax.legend()
ax.set_title('Subplot title')
ax.set_xlabel('sample x label')
ax.set_ylabel('sample y label')
ax.grid()
plt.show()

# vim:et ts=4 sts=4 sw=4
