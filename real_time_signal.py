import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import random


def read_potentiometer():
    # Replace this with the actual code to read the potentiometer value
    return random.uniform(0, 1)

# Set up the figure and axis
fig, ax = plt.subplots()
x_data, y_data = [], []
line, = ax.plot([], [], lw=2)

def init():
    ax.set_ylim(0, 1)
    ax.set_xlim(0, 100)
    return line,

def update(frame):
    value = read_potentiometer()
    x_data.append(frame)
    y_data.append(value)
    line.set_data(x_data, y_data)
    return line,

ani = FuncAnimation(fig, update, frames=range(100), init_func=init, blit=True, interval=100)

plt.show()
