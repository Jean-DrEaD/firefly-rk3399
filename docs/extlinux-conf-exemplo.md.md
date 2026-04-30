
### `docs/extlinux-conf-exemplo.md`

```markdown
# ⚙️ Exemplo de `extlinux.conf` para Firefly-RK3399 (Ubuntu BSP)

Localização: `/boot/extlinux/extlinux.conf`

## Conteúdo recomendado (boot via eMMC)

```text
label kernel-4.4
    kernel /Image
    fdt /rk3399-firefly.dtb
    append earlyprintk console=ttyFIQ0,1500000n8 rw \
           root=PARTLABEL=rootfs rootfstype=ext4 rootwait \
           storagenode=dwmmc@fe320000 \
           init=/sbin/init coherent_pool=1m
