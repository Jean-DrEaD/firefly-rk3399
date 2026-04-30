# Confirma que o root montado é do eMMC:
findmnt /
# Esperado: SOURCE=/dev/mmcblk0p7

# Confirma o controlador usado:
dmesg | grep -i "fe320000\|dwmmc"
