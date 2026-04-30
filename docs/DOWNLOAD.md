# 📥 Download de backups

Como **listar** e **baixar** backups publicados no Google Drive em qualquer máquina Linux.

---

## 🎯 Cenário típico

Você tem uma placa nova/zerada e quer aplicar um backup já publicado por você (ou por outro mantenedor) sem precisar gerar tudo de novo.

---

## 📋 Pré-requisitos

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
📦 Backups disponíveis:

┌────────────┬──────────┬──────────────────────────────┬──────────────────────────────────────┐
│ Data       │ Tamanho  │ Host                         │ Notas                                │
├────────────┼──────────┼──────────────────────────────┼──────────────────────────────────────┤
│ 2026-04-30 │ 3.2G     │ firefly (Ubuntu BSP 20.04)   │ Klipper/Mainsail pos-clone SD->eMMC  │
└────────────┴──────────┴──────────────────────────────┴──────────────────────────────────────┘

💡 Para baixar: ./scripts/07-download-backup.sh <data> [destino]
```

---

## 📥 Baixar um backup

### Sintaxe

```bash
./scripts/07-download-backup.sh <data> [diretorio-destino]
```

- `<data>`: chave `date` do manifest (ex: `2026-04-30`)
- `[diretorio-destino]`: opcional, padrão `/tmp`

### Exemplo

```bash
./scripts/07-download-backup.sh 2026-04-30 /tmp
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
[INFO]     Arquivo: firefly-backup-20260430.img.gz
[INFO]     Destino: /tmp/firefly-backup-20260430.img.gz
Downloading...
From (original): https://drive.google.com/uc?id=1TogEzG0hUVV140bq-y_jvWY609Mq1QKI
From (redirected): https://drive.google.com/uc?id=...&confirm=t&uuid=...
To: /tmp/firefly-backup-20260430.img.gz
100%|████████████| 3.34G/3.34G [09:23<00:00, 5.92MB/s]

[INFO] 📥 Baixando MD5 companheiro...
[INFO] 🔍 Validando MD5 (manifest)...
[INFO] ✅ MD5 manifest OK: 1ab974d2268be859fdcacaadca9b65cf
[INFO] 🔍 Validando MD5 (arquivo .md5)...
[INFO] ✅ MD5 file OK
[INFO] 🎉 Download concluido!

💡 Para restaurar:
   sudo ./scripts/99-restore-image.sh /tmp/firefly-backup-20260430.img.gz /dev/mmcblkX
```

---

## ⚡ Retomada de download

Se o download for interrompido (Ctrl+C, queda de rede, etc.), **rode o mesmo comando de novo**:

```bash
./scripts/07-download-backup.sh 2026-04-30 /tmp
```

O `gdown` detecta o arquivo parcial e retoma de onde parou (`--continue` interno do script).

> 💡 Para forçar redownload do zero, delete o arquivo antes:
> ```bash
> rm /tmp/firefly-backup-20260430.img.gz*
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
