import matplotlib.pyplot as plt
import numpy as np

# Define parameters for the waves
f1 = 1000  # 1 kHz
f2 = 1100  # 1.1 kHz
f3 = 1200  # 1.2 kHz

# Time values
t = np.linspace(0, 0.01, 1000)  # time from 0 to 0.01 seconds (10ms)

# Angular frequencies
omega1 = 2 * np.pi * f1
omega2 = 2 * np.pi * f2
omega3 = 2 * np.pi * f3

# Interference pattern for case (a): |E1 + E2|^2, ε1 = ε2 = x
E1_a = np.cos(omega1 * t)
E2_a = np.cos(omega2 * t)
interference_a = (E1_a + E2_a) ** 2

# Interference pattern for case (b): |E1 + E2|^2, ε1 = x, ε2 = y
# No interference term as the polarization vectors are orthogonal
interference_b = 2 * np.ones_like(t)

# Interference pattern for case (c): |E1 + E2|^2, ε1 = x, ε2 = (x + y)/sqrt(2)
E2_c = (1 / np.sqrt(2)) * (
    np.cos(omega2 * t) + np.sin(omega2 * t)
)  # Polarization vector in x + y direction
interference_c = (E1_a + E2_c) ** 2

# Interference pattern for case (d): |E1 + E2 + E3|^2, ε1 = ε2 = ε3 = x
E3_d = np.cos(omega3 * t)
interference_d = (E1_a + E2_a + E3_d) ** 2

# Plotting the results
plt.figure(figsize=(10, 8))

# Plot (a)
plt.subplot(2, 2, 1)
plt.plot(t, interference_a)
plt.title("(a)")
plt.xlabel("Time (s)")
plt.ylabel(r"$|E_1 + E_2|^2$")
plt.legend()

# Plot (b)
plt.subplot(2, 2, 2)
plt.plot(t, interference_b)
plt.title("(b)")
plt.xlabel("Time (s)")
plt.ylabel(r"$|E_1 + E_2|^2$")
plt.legend()

# Plot (c)
plt.subplot(2, 2, 3)
plt.plot(t, interference_c)
plt.title("(c)")
plt.xlabel("Time (s)")
plt.ylabel(r"$|E_1 + E_2|^2$")
plt.legend()

# Plot (d)
plt.subplot(2, 2, 4)
plt.plot(t, interference_d)
plt.title("(d)")
plt.xlabel("Time (s)")
plt.ylabel(r"$|E_1 + E_2 + E_3|^2$")
plt.legend()

plt.tight_layout()
plt.show()
