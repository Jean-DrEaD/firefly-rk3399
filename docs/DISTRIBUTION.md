# ☁️ Distribuição via Google Drive

Como **publicar** um backup no Google Drive e registrá-lo no manifest para que outras pessoas possam baixá-lo via [`07-download-backup.sh`](DOWNLOAD.md).

---

## 🎯 Por que Google Drive?

| Critério | Status |
|----------|:------:|
| Gratuito (15 GB) | ✅ |
| Suporta arquivos > 100 MB (limite do GitHub) | ✅ |
| Sem necessidade de Git LFS pago | ✅ |
| Links públicos compartilháveis | ✅ |
| Compatível com `gdown` (download CLI) | ✅ |
| Retomada de download | ✅ |

---

## 📋 Pré-requisitos

- Conta Google com espaço disponível
- Backup gerado conforme [`BACKUP.md`](BACKUP.md)
- Arquivos `firefly-backup-YYYYMMDD.img.gz` e `.md5` em mãos

---

## 🚀 Fluxo de publicação

### 1. Upload manual no Drive (web)

1. Acesse [drive.google.com](https://drive.google.com)
2. Crie pasta `firefly-backups/` (opcional, organização)
3. Arraste **os dois arquivos**:
   - `firefly-backup-YYYYMMDD.img.gz`
   - `firefly-backup-YYYYMMDD.img.gz.md5`
4. Aguarde upload completo (3-7 min para ~3 GB em conexão decente)

> 💡 **Por que upload manual?** O `gdown` é apenas para **download**. Upload via CLI exigiria OAuth e API setup — não vale a complexidade para fluxo ocasional.

---

### 2. Tornar arquivos públicos

Para **cada um dos dois arquivos**:

1. Clique com botão direito → **Compartilhar**
2. Em "Acesso geral", mude para **"Qualquer pessoa com o link"**
3. Permissão: **Leitor** (Viewer)
4. Clique em **Copiar link**

**Formato do link copiado:**

```
https://drive.google.com/file/d/1TogEzG0hUVV140bq-y_jvWY609Mq1QKI/view?usp=sharing
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                           Esse é o ID
```

**Anote os 2 IDs** (do `.img.gz` e do `.md5`).

---

### 3. Validar acesso público

Antes de registrar no manifest, **teste em aba anônima**:

```
https://drive.google.com/file/d/<ID>/view
```

- ✅ Deve carregar a página de preview sem pedir login
- ❌ Se aparecer "Precisa solicitar acesso" → revise compartilhamento

---

### 4. Atualizar o manifest `images/backups.json`

Adicione uma nova entrada no array `backups`:

```json
{
  "schema_version": "1.1",
  "backups": [
    {
      "date": "2026-06-18",
      "file": "firefly-backup-20260618-1603.img.gz",
      "md5_file": "firefly-backup-20260618-1603.img.gz.md5",
      "size_human": "4.0G",
      "size_bytes": 4199633243,
      "md5": "65a3e884a7f43fc78a258964997a1436",
      "gdrive_id": "16XIMkurfAEdXORyj1lDujwtGrSEW1dVc",
      "gdrive_md5_id": "1GEXBWVRh5eMP_SCReh4WYU14zdZXGF8p",
      "host": "firefly (AIO-3399C-AI Board)",
      "os": "Ubuntu 20.04.6 LTS aarch64",
      "kernel": "4.4.194",
      "notes": "can0 limpo via udev, Kalico estavel"
    }
  ]
}
```

**Como obter cada campo:**

| Campo | Como obter |
|-------|------------|
| `date` | Data do backup (`YYYY-MM-DD`) |
| `file` | Nome do arquivo `.img.gz` |
| `md5_file` | Nome do arquivo `.md5` |
| `size_human` | `du -h images/firefly-backup-*.img.gz` |
| `size_bytes` | `stat -c%s images/firefly-backup-*.img.gz` |
| `md5` | Conteúdo do arquivo `.md5` (primeiro campo) |
| `gdrive_id` | ID do link compartilhado do `.img.gz` |
| `gdrive_md5_id` | ID do link compartilhado do `.md5` |
| `host` | Nome amigável da placa |
| `os` | `lsb_release -d` na placa de origem |
| `kernel` | `uname -r` na placa de origem |
| `notes` | Descrição livre (1 linha) |

---

### 5. Validar JSON antes do commit

```bash
cat images/backups.json | jq .
# Se imprimir formatado e sem erro: OK
# Se reclamar: tem vírgula faltando ou aspas erradas
```

---

### 6. Commit + push

```bash
git add images/backups.json
git commit -m "manifest: adiciona backup YYYY-MM-DD"
git push origin main
```

---

## ✅ Validação final

Em outra máquina (ou no mesmo repo após `git pull`):

```bash
./scripts/06-list-backups.sh
# Deve listar a nova entrada

./scripts/07-download-backup.sh 2026-04-30 /tmp
# Deve baixar e validar MD5 com sucesso
```

---

## 🔐 Boas práticas

### Não publique dados sensíveis

**Antes de gerar o backup**, limpe:

```bash
# Histórico de comandos
history -c && rm ~/.bash_history

# Chaves SSH privadas (se quiser que cada placa tenha as suas)
rm -f /root/.ssh/id_* /home/*/.ssh/id_*

# Tokens, credenciais
rm -rf ~/.aws ~/.config/gh ~/.netrc

# Logs
sudo journalctl --vacuum-time=1d
sudo rm -rf /var/log/*.log

# Cache APT
sudo apt clean
```

### Versione apenas o manifest

O `.gitignore` já bloqueia `images/*.img.gz` e `images/*.md5`. **Confirme** antes de commitar:

```bash
git status
# images/backups.json deve aparecer
# .img.gz NUNCA deve aparecer
```

### Rotacione backups antigos

O Drive grátis tem 15 GB. Após acumular 3-4 backups:

1. Delete o mais antigo do Drive
2. Remova a entrada correspondente do `backups.json`
3. Commit + push

---

## 🔗 Próximos passos

- 📑 [Entender melhor o schema do manifest](MANIFEST.md)
- 📥 [Como usuários baixam](DOWNLOAD.md)
