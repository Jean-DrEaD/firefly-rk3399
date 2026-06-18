# 📥 Download de backups

Como **listar** e **baixar** backups publicados no Google Drive em qualquer máquina Linux.

---

## 🎯 Cenário típico

Você tem uma placa nova/zerada e quer aplicar um backup já publicado por você (ou por outro mantenedor) sem precisar gerar tudo de novo.

---

## ⚡ Download direto (sem git clone)

A imagem mais recente pode ser baixada diretamente, sem precisar clonar o repositório:

| Arquivo | Download | MD5 |
|---------|----------|-----|
| `firefly-backup-20260618-1603.img.gz` (4.0 GB) | [⬇️ Google Drive](https://drive.google.com/uc?export=download&id=16XIMkurfAEdXORyj1lDujwtGrSEW1dVc) | `65a3e884a7f43fc78a258964997a1436` |
| `firefly-backup-20260618-1603.img.gz.md5` | [⬇️ Google Drive](https://drive.google.com/uc?export=download&id=1GEXBWVRh5eMP_SCReh4WYU14zdZXGF8p) | — |

> 📦 Todas as versões disponíveis: [GitHub Releases](https://github.com/Jean-DrEaD/firefly-rk3399/releases)

Ou via `wget`/`curl` na linha de comando:

```bash
# Imagem
wget -O firefly-backup-20260618-1603.img.gz \
  "https://drive.google.com/uc?export=download&id=16XIMkurfAEdXORyj1lDujwtGrSEW1dVc"

# MD5 companheiro
wget -O firefly-backup-20260618-1603.img.gz.md5 \
  "https://drive.google.com/uc?export=download&id=1GEXBWVRh5eMP_SCReh4WYU14zdZXGF8p"

# Validar
md5sum -c firefly-backup-20260618-1603.img.gz.md5
```

> ⚠️ Para arquivos > 100 MB o Google Drive pode exibir aviso de antivírus. Se o `wget` baixar uma página HTML em vez da imagem, use `gdown` (veja seção abaixo) ou o script `07-download-backup.sh`.

---

## 📋 Pré-requisitos (download via script)

Veja [`INSTALL.md`](INSTALL.md) — Cenário 1.

**Resumo:**

```bash
sudo apt install -y jq pipx coreutils git
pipx ensurepath
pipx install gdown   # >= 6.0.0
```

---

## 📜 Listar backups disponíveis

```bash
cd firefly-rk3399
./scripts/06-list-backups.sh
```

**O que faz:**

- Lê o manifest [`images/backups.json`](../images/backups.json)
- Formata em tabela legível
- Mostra data, tamanho, host e notas de cada backup

**Saída esperada:**

```
[INFO] 📦 Backups disponíveis:

  📅 2026-06-18
     Arquivo:  firefly-backup-20260618-1603.img.gz
     Tamanho:  4.0G
     MD5:      65a3e884a7f43fc78a258964997a1436
     Host:     firefly (AIO-3399C-AI Board) (Ubuntu 20.04.6 LTS aarch64)
     Notas:    can0 limpo via udev (txqueuelen 128), Kalico estavel

  📅 2026-04-30
     Arquivo:  firefly-backup-20260430.img.gz
     Tamanho:  3.2G
     MD5:      1ab974d2268be859fdcacaadca9b65cf
     Host:     firefly (Ubuntu BSP 20.04) (Ubuntu 20.04 BSP aarch64)
     Notas:    Klipper/Mainsail pos-clone SD->eMMC

[INFO] Para baixar: ./07-download-backup.sh <YYYY-MM-DD> [destino]
```

---

## 📥 Baixar um backup

### Sintaxe

```bash
./scripts/07-download-backup.sh <data> [diretorio-destino]
```

- `<data>`: chave `date` do manifest (ex: `2026-06-18`)
- `[diretorio-destino]`: opcional, padrão `/tmp`

### Exemplo

```bash
./scripts/07-download-backup.sh 2026-06-18 /tmp
```

**Fluxo automatizado:**

1. ✅ Lê o manifest e busca a entrada da data
2. ☁️ Baixa o `.img.gz` via `gdown` (com retomada `--continue`)
3. ☁️ Baixa o `.md5` companheiro
4. 🔍 Valida MD5 contra o valor do manifest
5. 🔍 Valida MD5 contra o conteúdo do arquivo `.md5`
6. 📋 Imprime comando de restauração pronto

**Saída esperada:**

```
[INFO] 📥 Baixando imagem do Google Drive...
[INFO]     Arquivo: firefly-backup-20260618-1603.img.gz
[INFO]     Destino: /tmp/firefly-backup-20260618-1603.img.gz
Downloading...
From (original): https://drive.google.com/uc?id=16XIMkurfAEdXORyj1lDujwtGrSEW1dVc
From (redirected): https://drive.google.com/uc?id=...&confirm=t&uuid=...
To: /tmp/firefly-backup-20260618-1603.img.gz
100%|████████████| 4.00G/4.00G [11:12<00:00, 5.94MB/s]

[INFO] 📥 Baixando MD5 companheiro...
[INFO] 🔍 Validando MD5 (manifest)...
[INFO] ✅ MD5 manifest OK: 65a3e884a7f43fc78a258964997a1436
[INFO] 🔍 Validando MD5 (arquivo .md5)...
[INFO] ✅ MD5 file OK
[INFO] 🎉 Download concluído com sucesso!
[INFO]     /tmp/firefly-backup-20260618-1603.img.gz

[INFO] Para restaurar:
[INFO]     sudo ./scripts/99-restore-image.sh /tmp/firefly-backup-20260618-1603.img.gz /dev/mmcblkX
```

---

## ⚡ Retomada de download

Se o download for interrompido (Ctrl+C, queda de rede, etc.), **rode o mesmo comando de novo**:

```bash
./scripts/07-download-backup.sh 2026-06-18 /tmp
```

O `gdown` detecta o arquivo parcial e retoma de onde parou (`--continue` interno do script).

> 💡 Para forçar redownload do zero, delete o arquivo antes:
> ```bash
> rm /tmp/firefly-backup-20260618-1603.img.gz*
> ```

---

## 🔒 Por que validação MD5 dupla?

O script valida o checksum **duas vezes**, com fontes independentes:

| Fonte | Vantagem |
|-------|----------|
| **Manifest** (`backups.json`) | Versionado no Git — qualquer alteração indevida vira commit visível |
| **Arquivo `.md5`** (no Drive) | Vem junto com a imagem — detecta corrupção de upload |

Se as duas conferem **e** batem entre si, a imagem é **garantidamente íntegra**. ✅

---

## 🐛 Problemas comuns

### `gdown: error: unrecognized arguments: --fuzzy`

Você tem `gdown < 6`. Atualize:

```bash
pipx install --force gdown
gdown --version
```

### `Permission denied` ao baixar

O arquivo no Drive não está público. Confirme:
1. Abra o link `https://drive.google.com/file/d/<ID>/view` em aba anônima
2. Deve carregar sem login
3. Se pedir login, ajuste compartilhamento para "Qualquer pessoa com o link"

### MD5 não confere

1. Tente baixar de novo (corrupção em trânsito é raro mas acontece)
2. Confirme `gdrive_id` no manifest
3. Veja [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md#md5-mismatch)

---

## 🔗 Próximos passos

- ♻️ [Restaurar a imagem baixada](RESTORE.md)
- 📑 [Entender o manifest](MANIFEST.md)
