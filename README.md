# 🔥 Firefly-RK3399 — Ubuntu BSP atualizado

Documentação e scripts do processo de **migração, clonagem e backup** da placa
**Firefly-RK3399** rodando o **Ubuntu BSP 20.04 (Focal)** oficial da Firefly —
distribuição baseada no kernel/U-Boot da Rockchip com layout de partições
proprietário (GPT com `loader1`, `loader2`, `trust`, `misc`, etc.).

> ⚠️ **Importante:** Este projeto **NÃO** usa Armbian. O Ubuntu BSP da Firefly
> tem layout de partições **muito diferente** do Armbian, e os procedimentos
> aqui descritos consideram essa especificidade (parâmetros de boot via
> `extlinux.conf`, controlador `dwmmc@fe320000`, partições raw do Rockchip).

---

## 🎯 Objetivo

Instalação completa do **Klipper / Mainsail / Moonraker / KlipperScreen / Shake & Tune**
no **eMMC interno de 16 GB**, garantindo:

- ✅ Maior performance de I/O (eMMC > SD)
- ✅ Maior confiabilidade (eMMC não sofre o desgaste típico de SDs)
- ✅ Estratégia de **Disaster Recovery** com imagem `.img.gz` validada
- ✅ SD original preservado como **spare** para hot-swap em caso de falha

---

## 💻 Hardware & Software

| Item | Especificação |
|------|---------------|
| **SBC** | Firefly-RK3399 |
| **SoC** | Rockchip RK3399 (2× Cortex-A72 + 4× Cortex-A53) |
| **OS** | Ubuntu BSP 20.04 (Focal) — build oficial Firefly |
| **Origem** | SD Card 64 GB → `/dev/mmcblk2` |
| **Destino** | eMMC 16 GB → `/dev/mmcblk0` |
| **Controlador eMMC** | `dwmmc@fe320000` |
| **Bootloader** | U-Boot Rockchip + `extlinux.conf` |
| **Serviços críticos** | Klipper, Mainsail, Moonraker, KlipperScreen |

---

## 🗂️ Layout de Partições (Ubuntu BSP Firefly)

O Ubuntu BSP da Firefly usa um esquema **GPT** com partições raw específicas
do Rockchip que **não devem** ser tratadas como FS comuns:

| Partição | Conteúdo | Tipo | Ação no clone |
|----------|----------|------|---------------|
| `p1` | `loader1` (idbloader) | raw | Validar via MD5 |
| `p2` | `reserved` / `uboot` | raw | Validar via MD5 |
| `p3` | `misc` | raw | Validar via MD5 |
| `p4` | `boot` (kernel + dtb) | ext4 | **Clonar com `dd`** |
| `p5` | `recovery` | raw | Validar via MD5 |
| `p6` | `backup` | raw | Validar via MD5 |
| `p7` | `rootfs` | ext4 | **Clonar com `dd`** |
| `p8` | `userdata` | ext4 | **Clonar com `dd`** |

---

## 🚀 Etapas do Procedimento

### 1️⃣ Verificação das partições raw (idênticas no SD e no eMMC de fábrica)

Antes de clonar, validamos via **MD5** que as partições do Rockchip
(`p1, p2, p3, p5, p6`) já são idênticas entre SD e eMMC — confirmando que
**só precisamos clonar `p4`, `p7` e `p8`**:

```bash
for p in 1 2 3 5 6; do
    md5_sd=$(sudo dd if=/dev/mmcblk2p$p bs=4M status=none | md5sum | awk '{print $1}')
    md5_em=$(sudo dd if=/dev/mmcblk0p$p bs=4M status=none | md5sum | awk '{print $1}')
    echo "p$p  SD=$md5_sd  eMMC=$md5_em"
done
