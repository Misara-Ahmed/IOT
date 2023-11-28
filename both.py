import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
from matplotlib.animation import FuncAnimation
import random

# Assuming you have a function to read the potentiometer values
def read_potentiometer1():
    return random.uniform(80, 160)

def read_potentiometer2():
    return random.uniform(0, 100)

def read_potentiometer():
    return random.uniform(0, 1)

class RealTimeCombinedApp:
    def __init__(self, master):
        self.master = master
        self.master.title("Real-Time Potentiometer Readings")

        # Create a single figure for both labels and real-time plot
        self.fig = Figure()
        
        # Labels
        self.title_label1 = tk.Label(master=self.master, text="Heart rate", font=("Helvetica", 16))
        self.title_label1.pack()

        self.value_label1 = tk.Label(master=self.master, text="", font=("Helvetica", 48))
        self.value_label1.pack()

        self.title_label2 = tk.Label(master=self.master, text="Oxygen Concentration", font=("Helvetica", 16))
        self.title_label2.pack()

        self.value_label2 = tk.Label(master=self.master, text="", font=("Helvetica", 48))
        self.value_label2.pack()

        # Matplotlib setup for real-time plotting
        self.ax = self.fig.add_subplot(1, 1, 1)
        self.line, = self.ax.plot([], [], lw=2)

        self.canvas = FigureCanvasTkAgg(self.fig, master=self.master)
        self.canvas.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=1)

        self.ax.set_ylim(0, 1)
        self.ax.set_xlim(0, 100)

        # Animation setup
        self.ani = FuncAnimation(self.fig, self.update, frames=range(100), init_func=self.init, blit=True, interval=100)

        # Start updating numbers and the plot
        self.update_numbers()

    def init(self):
        return self.line,

    def update(self, frame):
        value = read_potentiometer()
        self.x_data = list(self.line.get_xdata())
        self.y_data = list(self.line.get_ydata())

        self.x_data.append(frame)
        self.y_data.append(value)

        # Limit the data to the last 100 points for better visualization
        self.x_data = self.x_data[-100:]
        self.y_data = self.y_data[-100:]

        self.line.set_data(self.x_data, self.y_data)

        # Update the matplotlib plot canvas
        self.canvas.draw()

        return self.line,

    def update_numbers(self):
        value1 = read_potentiometer1()
        value2 = read_potentiometer2()

        self.value_label1.config(text=f"{value1:.2f}")
        self.value_label2.config(text=f"{value2:.2f}")

        self.master.after(1000, self.update_numbers)  # Update every 1000 milliseconds (1 second)

if __name__ == "__main__":
    root = tk.Tk()
    app = RealTimeCombinedApp(root)
    root.mainloop()
