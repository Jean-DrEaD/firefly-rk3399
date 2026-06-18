# 🔥 firefly-rk3399 — Release v2026.06.18

> Imagem completa da eMMC do Firefly AIO-3399C-AI com Ubuntu 20.04.6 LTS + Kalico (can0/udev).

---

## 📦 Download direto

| Arquivo | Tamanho | Download |
|---------|---------|----------|
| `firefly-backup-20260618-1603.img.gz` | 4.0 GB | [⬇️ Google Drive](https://drive.google.com/uc?export=download&id=16XIMkurfAEdXORyj1lDujwtGrSEW1dVc) |
| `firefly-backup-20260618-1603.img.gz.md5` | < 1 KB | [⬇️ Google Drive](https://drive.google.com/uc?export=download&id=1GEXBWVRh5eMP_SCReh4WYU14zdZXGF8p) |

**MD5:** `65a3e884a7f43fc78a258964997a1436`

> ⚠️ O Google Drive pode exibir aviso de antivírus para arquivos > 100 MB. Se o download via browser travar, use `gdown` (instruções abaixo) ou o script `07-download-backup.sh`.

---

## 🖥️ Ambiente capturado

| Campo | Valor |
|-------|-------|
| **Host** | Firefly AIO-3399C-AI Board |
| **OS** | Ubuntu 20.04.6 LTS aarch64 |
| **Kernel** | 4.4.194 |
| **Tamanho (comprimido)** | 4.0 GB (`gzip -1`) |
| **Tamanho (bytes)** | 4.199.633.243 |
| **Gerado em** | 2026-06-18 às 16:03 |
| **Schema manifest** | v1.1 |

**Configurações incluídas:**
- `can0` configurado via udev com `txqueuelen 128`
- Kalico estável rodando
- eMMC validado pós-clone SD → eMMC

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
./scripts/07-download-backup.sh 2026-06-18 /tmp
```

### Opção 2 — Download direto via `gdown`

```bash
pip install gdown   # ou: pipx install gdown

# Imagem
gdown 16XIMkurfAEdXORyj1lDujwtGrSEW1dVc -O firefly-backup-20260618-1603.img.gz

# MD5 companheiro
gdown 1GEXBWVRh5eMP_SCReh4WYU14zdZXGF8p -O firefly-backup-20260618-1603.img.gz.md5

# Validar
md5sum -c firefly-backup-20260618-1603.img.gz.md5
```

### Opção 3 — Download via `wget` (atenção: pode baixar página HTML em vez da imagem)

```bash
wget -O firefly-backup-20260618-1603.img.gz \
  "https://drive.google.com/uc?export=download&id=16XIMkurfAEdXORyj1lDujwtGrSEW1dVc"

wget -O firefly-backup-20260618-1603.img.gz.md5 \
  "https://drive.google.com/uc?export=download&id=1GEXBWVRh5eMP_SCReh4WYU14zdZXGF8p"

# Validar
md5sum -c firefly-backup-20260618-1603.img.gz.md5
```

---

## ♻️ Restaurar em SD ou eMMC

```bash
# Identifique o dispositivo destino primeiro!
lsblk

# Restaurar (substitua /dev/mmcblkX pelo dispositivo correto)
sudo ./scripts/99-restore-image.sh /tmp/firefly-backup-20260618-1603.img.gz /dev/mmcblkX
```

> 🚨 **ATENÇÃO:** O script apaga **tudo** no dispositivo destino. Confirme o caminho `/dev/...` antes de prosseguir.

Veja [`docs/RESTORE.md`](docs/RESTORE.md) para o guia completo.

---

## 🔒 Validação de integridade

```bash
# Após baixar, confira o MD5:
md5sum firefly-backup-20260618-1603.img.gz
# Esperado: 65a3e884a7f43fc78a258964997a1436

# Ou validando contra o arquivo .md5:
md5sum -c firefly-backup-20260618-1603.img.gz.md5
# Esperado: firefly-backup-20260618-1603.img.gz: OK
```

---

## 📚 Documentação

- 📥 [DOWNLOAD.md](docs/DOWNLOAD.md) — Download e validação detalhados
- ♻️ [RESTORE.md](docs/RESTORE.md) — Restauração passo a passo
- 🔧 [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) — Problemas comuns

---

## 📋 Releases anteriores

| Versão | Data | Tamanho | Notas |
|--------|------|---------|-------|
| v2026.04.30 | 2026-04-30 | 3.2 GB | Klipper/Mainsail pós-clone SD→eMMC |
