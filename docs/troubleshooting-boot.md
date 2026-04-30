
### `docs/troubleshooting-boot.md`

```markdown
# 🔧 Troubleshooting de Boot — Firefly-RK3399

## Sintoma 1: Sistema boota pelo SD mesmo com eMMC válido

**Causa:** O BootROM da Rockchip prioriza o SD card quando presente.

**Solução:**
- Ajustar o `extlinux.conf` do **SD** para apontar para o eMMC (`storagenode=dwmmc@fe320000`)
- Ou simplesmente **remover o SD** após confirmar que o eMMC está ok

---

## Sintoma 2: Kernel panic — "unable to mount root fs"

**Causa:** Conflito de PARTLABEL/UUID entre SD e eMMC após clone.

**Solução:**
1. Boot pelo SD original
2. Montar o eMMC manualmente:
   ```bash
   sudo mount /dev/mmcblk0p7 /mnt
   sudo nano /mnt/boot/extlinux/extlinux.conf
