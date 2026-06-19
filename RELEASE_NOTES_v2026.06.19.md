# 🔥 firefly-rk3399 — Release v2026.06.19

> Imagem completa da eMMC do Firefly AIO-3399C-AI com Ubuntu 20.04.6 LTS + Kalico + eddy-ng — boot corrigido.

---

## 📦 Download direto

| Arquivo | Tamanho | Download |
|---------|---------|----------|
| `firefly-backup-20260619-1950.img.gz` | 3.9 GB | [⬇️ Google Drive](https://drive.google.com/uc?export=download&id=1xzBkba_JzHIuV5kOyZ4axnSN_KoXcTY3) |
| `firefly-backup-20260619-1950.img.gz.md5` | < 1 KB | [⬇️ Google Drive](https://drive.google.com/uc?export=download&id=1O32pbk3Qx_dULiD5V-K62AzXoEvq4t0H) |

**MD5:** `ac7349eab68fe2879ba58eb68400ce9d`

> ⚠️ O Google Drive pode exibir aviso de antivírus para arquivos > 100 MB. Se o download via browser travar, use `gdown` (instruções abaixo) ou o script `07-download-backup.sh`.

---

## 🖥️ Ambiente capturado

| Campo | Valor |
|-------|-------|
| **Host** | Firefly AIO-3399C-AI Board |
| **OS** | Ubuntu 20.04.6 LTS aarch64 |
| **Kernel** | 4.4.194 |
| **Tamanho (comprimido)** | 3.9 GB (`gzip -1`) |
| **Gerado em** | 2026-06-19 |
| **Schema manifest** | v1.1 |

**Configurações incluídas:**
- Boot corrigido (problemas de inicialização resolvidos pós 2026-06-18)
- `eddy-ng` instalado e atualizado
- `can0` configurado via udev com `txqueuelen 128`
- Kalico estável rodando

---

## ⚡ Como usar

### Opção 1 — Download via script (recomendado, com validação MD5)

```bash
git clone https://github.com/Jean-DrEaD/firefly-rk3399.git
cd firefly-rk3399
chmod +x scripts/*.sh

# Instala dependências (se ainda não instaladas)
sudo apt install -y jq pipx coreutils
pipx install gdown   # >= 6.0.0

# Baixa e valida automaticamente
./scripts/07-download-backup.sh 2026-06-19 /tmp
```

### Opção 2 — Download direto via `gdown`

```bash
pip install gdown   # ou: pipx install gdown

# Preencha com os IDs reais após upload:
gdown 1xzBkba_JzHIuV5kOyZ4axnSN_KoXcTY3 -O firefly-backup-20260619-1950.img.gz
gdown 1O32pbk3Qx_dULiD5V-K62AzXoEvq4t0H -O firefly-backup-20260619-1950.img.gz.md5

# Validar
md5sum -c firefly-backup-20260619-1950.img.gz.md5
```

---

## ♻️ Restaurar em SD ou eMMC

```bash
# Identifique o dispositivo destino primeiro!
lsblk

# Restaurar (substitua /dev/mmcblkX pelo dispositivo correto)
sudo ./scripts/99-restore-image.sh /tmp/firefly-backup-20260619-1950.img.gz /dev/mmcblkX
```

> 🚨 **ATENÇÃO:** O script apaga **tudo** no dispositivo destino. Confirme o caminho `/dev/...` antes de prosseguir.

Veja [`docs/RESTORE.md`](docs/RESTORE.md) para o guia completo.

---

## 📚 Documentação

- 📥 [DOWNLOAD.md](docs/DOWNLOAD.md) — Download e validação detalhados
- ♻️ [RESTORE.md](docs/RESTORE.md) — Restauração passo a passo
- 🔧 [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) — Problemas comuns

---

## 📋 Releases anteriores

| Versão | Data | Tamanho | Notas |
|--------|------|---------|-------|
| v2026.06.18 | 2026-06-18 | 4.0 GB | can0/udev, Kalico estável |
| v2026.04.30 | 2026-04-30 | 3.2 GB | Klipper/Mainsail pós-clone SD→eMMC |
