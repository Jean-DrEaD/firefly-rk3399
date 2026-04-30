# 🗂️ Particionamento do Ubuntu BSP 20.04 (Firefly-RK3399)

O Ubuntu BSP oficial da Firefly utiliza um esquema **GPT** com partições raw
específicas da Rockchip que **não são filesystems comuns** e não devem ser
montadas/formatadas.

## Tabela completa

| # | Nome | Tipo | Tamanho típico | Conteúdo | Operação no clone |
|---|------|------|----------------|----------|-------------------|
| `p1` | `loader1` | raw | 4 MB | idbloader (SPL + DDR init) | Validar MD5 |
| `p2` | `reserved` | raw | 4 MB | Reservado / U-Boot ext | Validar MD5 |
| `p3` | `misc` | raw | 4 MB | Misc / parâmetros | Validar MD5 |
| `p4` | `boot` | ext4 | 112 MB | Kernel + DTB + extlinux | **Clonar (`dd`)** |
| `p5` | `recovery` | raw | 32 MB | Recovery image | Validar MD5 |
| `p6` | `backup` | raw | 8 MB | Slot de backup do BSP | Validar MD5 |
| `p7` | `rootfs` | ext4 | ~6 GB | Sistema raiz Ubuntu | **Clonar (`dd`)** |
| `p8` | `userdata` | ext4 | restante | Dados do usuário (Klipper, etc.) | **Clonar (`dd`)** |

## Verificação no sistema

```bash
sudo parted /dev/mmcblk0 print
sudo gdisk -l /dev/mmcblk0
lsblk -o NAME,SIZE,TYPE,FSTYPE,PARTLABEL,MOUNTPOINT
