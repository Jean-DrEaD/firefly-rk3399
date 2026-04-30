# 📑 Manifest `backups.json`

Documentação completa do **schema** e convenções do arquivo [`images/backups.json`](../images/backups.json), que cataloga todos os backups disponíveis.

---

## 🎯 Por que existe?

O manifest é **a única fonte da verdade versionada** sobre quais backups existem, onde estão e como validá-los. Ele permite:

- 📋 Listar backups sem acessar o Drive
- 🔒 Validar integridade (MD5 imutável no Git)
- 🤖 Automação (scripts leem JSON, não páginas web)
- 📜 Histórico via `git log` (quando cada backup foi adicionado/removido)

---

## 📐 Schema (versão 1.0)

```json
{
  "schema_version": "1.0",
  "backups": [
    {
      "date": "2026-04-30",
      "filename": "firefly-backup-20260430.img.gz",
      "size": "3.2G",
      "size_bytes": 3435973837,
      "md5": "1ab974d2268be859fdcacaadca9b65cf",
      "gdrive_id": "1TogEzG0hUVV140bq-y_jvWY609Mq1QKI",
      "gdrive_md5_id": "1AbCdEfGhIjKlMnOpQrStUvWxYz123456",
      "host": "firefly (Ubuntu BSP 20.04)",
      "kernel": "4.4.194",
      "notes": "Klipper/Mainsail pos-clone SD->eMMC"
    }
  ]
}
```

---

## 🔑 Campos do objeto `backup`

### Obrigatórios

| Campo | Tipo | Descrição | Exemplo |
|-------|------|-----------|---------|
| `date` | string | Data do backup, formato `YYYY-MM-DD` (ISO 8601). Usado como **chave de busca** pelos scripts. | `"2026-04-30"` |
| `filename` | string | Nome do arquivo `.img.gz` (deve corresponder ao publicado no Drive) | `"firefly-backup-20260430.img.gz"` |
| `md5` | string | Hash MD5 hexadecimal (32 chars) da imagem comprimida | `"1ab974d22...65cf"` |
| `gdrive_id` | string | ID do arquivo `.img.gz` no Google Drive | `"1TogEzG0hU...QKI"` |
| `gdrive_md5_id` | string | ID do arquivo `.md5` companheiro no Google Drive | `"1AbCdEfGh...456"` |

### Opcionais (recomendados)

| Campo | Tipo | Descrição | Exemplo |
|-------|------|-----------|---------|
| `size` | string | Tamanho legível (`du -h`) | `"3.2G"` |
| `size_bytes` | number | Tamanho exato em bytes (`stat -c%s`) | `3435973837` |
| `host` | string | Identificação amigável da origem | `"firefly (Ubuntu BSP 20.04)"` |
| `kernel` | string | Versão do kernel (`uname -r`) | `"4.4.194"` |
| `notes` | string | Descrição livre (1 linha) | `"Klipper pos-clone"` |

---

## 📏 Convenções

### Ordenação

**Backups mais recentes primeiro.** O `06-list-backups.sh` exibe na ordem do JSON.

### Imutabilidade

Uma vez adicionada uma entrada, **não edite** os campos `md5`, `gdrive_id`, `size_bytes`. Se precisar republicar, **adicione nova entrada com data nova**.

### Remoção

Para remover backup antigo:

1. Delete o arquivo do Google Drive
2. Remova a entrada correspondente do array `backups`
3. Commit com mensagem `manifest: remove backup YYYY-MM-DD (rotacao)`

---

## ✅ Validação

### Sintaxe JSON

```bash
jq . images/backups.json
# Se reformatar sem erro: válido
```

### Schema esperado

```bash
# Verifica se todos os backups têm os campos obrigatórios:
jq -e '.backups | all(has("date") and has("filename") and has("md5") and has("gdrive_id"))' images/backups.json
# Saída esperada: true
```

### Listar todas as datas

```bash
jq -r '.backups[].date' images/backups.json
```

### Buscar entrada específica

```bash
jq '.backups[] | select(.date == "2026-04-30")' images/backups.json
```

---

## 🔄 Migrações futuras de schema

O campo `schema_version` permite evolução sem quebrar consumidores antigos:

| Versão | Mudanças |
|--------|----------|
| `1.0` | Schema inicial (atual) |
| `1.1` | _futuro: campo `tags[]` para categorização_ |
| `2.0` | _futuro: suporte a múltiplos mirrors (não só Drive)_ |

Scripts devem checar `schema_version` antes de processar e avisar se for desconhecida.

---

## 📋 Template para nova entrada

Copie e ajuste:

```json
{
  "date": "YYYY-MM-DD",
  "filename": "firefly-backup-YYYYMMDD.img.gz",
  "size": "?G",
  "size_bytes": 0,
  "md5": "________________________________",
  "gdrive_id": "________________________________",
  "gdrive_md5_id": "________________________________",
  "host": "firefly (?)",
  "kernel": "?",
  "notes": "?"
}
```

**Comandos para preencher:**

```bash
cd images/

echo "size:        $(du -h firefly-backup-*.img.gz | cut -f1)"
echo "size_bytes:  $(stat -c%s firefly-backup-*.img.gz)"
echo "md5:         $(md5sum firefly-backup-*.img.gz | cut -d" " -f1)"
echo "kernel:      $(uname -r)   # rode na placa de origem"
```

---

## 🔗 Relacionados

- ☁️ [Como publicar (passo a passo)](DISTRIBUTION.md)
- 📥 [Como scripts consomem o manifest](DOWNLOAD.md)
