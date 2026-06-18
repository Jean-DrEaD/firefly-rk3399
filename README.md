# 🔥 firefly-rk3399

> Toolkit de **clonagem, backup e distribuição** de sistemas Linux para placas **Rockchip RK3399** (Firefly, NanoPi, Orange Pi), com foco em migração **SD → eMMC** e replicação de imagens via **Google Drive**.

[![Bash](https://img.shields.io/badge/Bash-5.x-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-RK3399-red)](https://www.rock-chips.com/a/en/products/RK33_Series/2016/0419/758.html)
[![gdown](https://img.shields.io/badge/gdown-6.x-blue)](https://github.com/wkentaro/gdown)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/Jean-DrEaD/firefly-rk3399?label=latest%20image)](https://github.com/Jean-DrEaD/firefly-rk3399/releases/latest)

---

## 📦 Download direto da imagem mais recente

> **Última imagem:** `firefly-backup-20260618-1603.img.gz` — 4.0 GB — Ubuntu 20.04.6 LTS aarch64 + Kalico (can0/udev)

| Arquivo | Link | MD5 |
|---------|------|-----|
| `firefly-backup-20260618-1603.img.gz` | [⬇️ Google Drive](https://drive.google.com/uc?export=download&id=16XIMkurfAEdXORyj1lDujwtGrSEW1dVc) | `65a3e884a7f43fc78a258964997a1436` |
| `firefly-backup-20260618-1603.img.gz.md5` | [⬇️ Google Drive](https://drive.google.com/uc?export=download&id=1GEXBWVRh5eMP_SCReh4WYU14zdZXGF8p) | — |

> Todas as imagens disponíveis e o histórico completo estão na página de [Releases](https://github.com/Jean-DrEaD/firefly-rk3399/releases).

---

## ⚡ Quick start

### Baixar um backup pronto em qualquer Linux

```bash
git clone https://github.com/Jean-DrEaD/firefly-rk3399.git
cd firefly-rk3399
chmod +x scripts/*.sh

# Lista backups disponíveis no Google Drive
./scripts/06-list-backups.sh

# Baixa a imagem mais recente (com validacao MD5 dupla)
./scripts/07-download-backup.sh 2026-06-18 /tmp

# Restaura em um SD/eMMC (CUIDADO com o destino!)
sudo ./scripts/99-restore-image.sh /tmp/firefly-backup-20260618-1603.img.gz /dev/mmcblk1
```

> 📋 **Pré-requisitos**: `jq`, `gdown` (>= 6.0), `md5sum`. Veja [`docs/INSTALL.md`](docs/INSTALL.md).

---

## 📚 Documentação

| Doc | Conteúdo |
|-----|----------|
| 📦 [`INSTALL.md`](docs/INSTALL.md) | Pré-requisitos e instalação em cada cenário |
| 🧬 [`CLONING.md`](docs/CLONING.md) | Migração SD → eMMC (scripts 01-04) |
| 💾 [`BACKUP.md`](docs/BACKUP.md) | Como gerar imagens da eMMC (script 05) |
| ☁️ [`DISTRIBUTION.md`](docs/DISTRIBUTION.md) | Publicar backups no Google Drive |
| 📥 [`DOWNLOAD.md`](docs/DOWNLOAD.md) | Baixar e validar backups (scripts 06-07) |
| ♻️ [`RESTORE.md`](docs/RESTORE.md) | Restaurar imagem em SD/eMMC (script 99) |
| 📑 [`MANIFEST.md`](docs/MANIFEST.md) | Schema do `backups.json` |
| 🔧 [`TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Problemas comuns e soluções |

---

## 🗂️ Estrutura

```
firefly-rk3399/
├── images/
│   ├── backups.json                  # Manifest (versionado)
│   └── *.img.gz                      # Imagens (ignoradas — ficam no Drive)
├── scripts/
│   ├── 00-common.sh                  # Funcoes compartilhadas
│   ├── 01-validate-raw-partitions.sh
│   ├── 02-clone-boot.sh
│   ├── 03-clone-rootfs.sh
│   ├── 04-clone-userdata.sh
│   ├── 05-backup-emmc.sh
│   ├── 06-list-backups.sh
│   ├── 07-download-backup.sh
│   └── 99-restore-image.sh
├── docs/                             # 📚 Documentacao modular
├── .gitattributes                    # Forca LF em scripts
├── .gitignore                        # Bloqueia *.img.gz
├── LICENSE
└── README.md
```

---

## ✨ Recursos

- 🧬 **Clonagem partição-a-partição** preservando UUIDs e flags de boot
- 💾 **Backup full-disk** comprimido com MD5 duplo
- ☁️ **Distribuição via Google Drive** sem expor binários no Git
- 📥 **Download automatizado** com retomada (`gdown --continue`)
- 🔒 **Validação MD5 dupla** (manifest + arquivo `.md5`)
- 📝 **Manifest JSON versionado** (histórico completo de backups)
- ⚡ **Compatível com gdown 6.x** (extração automática de ID)

---

## ✅ Casos testados

| Cenário | Status |
|---------|:------:|
| Firefly RK3399 + Ubuntu BSP 20.04 + Klipper/Mainsail | ✅ |
| Migração SD (32 GB) → eMMC (16 GB) | ✅ |
| Backup completo (3.2 GB comprimido) | ✅ |
| Upload + download via Google Drive público | ✅ |
| Download em Raspberry Pi 3B (Bookworm) | ✅ |
| Validação MD5 dupla pós-download | ✅ |
| `gdown 6.0.0` (sem `--fuzzy`) | ✅ |
| Firefly AIO-3399C-AI + Ubuntu 20.04.6 + Kalico (can0/udev, txqueuelen 128) | ✅ |
| Backup completo 4.0 GB — schema manifest v1.1 (2026-06-18) | ✅ |

---

## 🤝 Contribuições

PRs são bem-vindos! Diretrizes:

- Mantenha line endings em **LF** (já forçado por `.gitattributes`)
- Teste scripts com `bash -n script.sh` antes de commitar
- Atualize o doc relevante em `docs/` se mudar comportamento
- Siga o padrão de logs do `00-common.sh` (`log_info`, `log_warn`, `log_err`)

---

## 📄 Licença

[MIT](LICENSE) © Jean-DrEaD
