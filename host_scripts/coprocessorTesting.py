# coprocessorTesting.py
import numpy as np
from dev_cmd import *

np.random.seed()

N = 1024

# Se generan N números aleatorios de 0 a 255
A = np.random.randint(0, high=256, size=N, dtype=np.int32)
B = np.random.randint(0, high=256, size=N, dtype=np.int32)

# Se almacenan los vectores en formato .npy para acelerar la lectura
# posterior
np.save('VectorA.npy', A)
np.save('VectorB.npy', B)

# NumPy se encarga de forma automática de la suma elemento a elemento
# de los vectores, así como la división de sus elementos por un escalar
sum_vec_host = A + B
avg_vec_host = (A + B) / 2

# En la FPGA se calcula el valor absoluto comparando los operandos previo
# a la operación para restar el mayor de los dos valores leídos de la
# BRAMA y BRAMB del menor
man_host = np.linalg.norm(A - B, ord=1)
euc_host = np.linalg.norm(A - B)

# IMPORTANTE: cambiar el puerto serial según indique el administrador
# de dispositivos de su equipo
COM_port = 'COM4'

# Operación de escritura
write_to_dev('VectorA.npy', 'BRAMA', COM_port)
write_to_dev('VectorB.npy', 'BRAMB', COM_port)

# Operación de lectura
vecA_device = cmd_to_dev('readVec', 'BRAMA', COM_port)
vecB_device = cmd_to_dev('readVec', 'BRAMB', COM_port)

# Sumas y promedios
sum_vec_device = cmd_to_dev('sumVec', com=COM_port)
avg_vec_device = cmd_to_dev('avgVec', com=COM_port)

# Cálculo de distancias
man_device = cmd_to_dev('manDist', com=COM_port)
euc_device = cmd_to_dev('eucDist', com=COM_port)

# Errores de cómputo entre lo calculado por el host y el device
sum_vec_diff = np.sum(sum_vec_host - sum_vec_device)
avg_vec_diff = np.sum(avg_vec_host - avg_vec_device)
man_diff = man_host - man_device
euc_diff = euc_host - euc_device

print('Suma de errores en la operación suma: {}'.format(sum_vec_diff))
print('Suma de errores en la operación promedio: {}'.format(avg_vec_diff))
print('Distancia de Manhattan. Host: {:2.f} - Device: {} - Diff: {:.2f}'.format(man_host, man_device, man_diff))
print('Distancia euclideana. Host: {:2.f} - Device: {} - Diff: {:.2f}'.format(euc_host, euc_device, euc_diff))

