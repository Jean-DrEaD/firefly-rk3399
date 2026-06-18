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

## 📐 Schema (versão 1.1 — atual)

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
>📜 Histórico: o schema 1.0 usava filename, size e kernel como obrigatórios. A partir do 1.1 os campos foram renomeados (file, size_human) e adicionados md5_file e os.

## 🔑 Campos do objeto `backup`

Obrigatórios
| Campo | Tipo | Descrição | Exemplo |
| --- | --- | --- | --- |
| date | string | Data do backup YYYY-MM-DD. Chave de busca dos scripts. | "2026-06-18" |
| file | string | Nome do arquivo .img.gz publicado no Drive | "firefly-backup-20260618-1603.img.gz" |
| md5_file | string | Nome do arquivo .md5 companheiro | "firefly-backup-20260618-1603.img.gz.md5" |
| md5 | string | Hash MD5 hexadecimal (32 chars) da imagem | "65a3e884...1436" |
| gdrive_id | string | ID do .img.gz no Google Drive | "16XIMku...1dVc" |
| gdrive_md5_id | string | ID do .md5 companheiro no Google Drive | "1GEXBWV...XGF8p" |

Opcionais (recomendados)
| Campo | Tipo | Descrição | Exemplo |
| --- | --- | --- | --- |
| size_human | string | Tamanho legível (du -h) | "4.0G" |
| size_bytes | number | Tamanho exato em bytes (stat -c%s) | 4199633243 |
| host | string | Identificação da origem | "firefly (AIO-3399C-AI Board)" |
| os | string | Sistema operacional (lsb_release -d) | "Ubuntu 20.04.6 LTS aarch64" |
| kernel | string | Versão do kernel (uname -r) | "4.4.194" |
| notes | string | Descrição livre (1 linha) | "Kalico estavel" |
---


## 📏 Convenções

Ordenação

Backups mais recentes primeiro. O `06-list-backups.sh` exibe na ordem do JSON.
Imutabilidade

Uma vez adicionada uma entrada, não edite os campos `md5`, `gdrive_id`, `size_bytes`. Se precisar republicar, adicione nova entrada com data nova.
Remoção

Para remover backup antigo:

1. Delete o arquivo do Google Drive
2. Remova a entrada correspondente do array `backups`
3. Commit com mensagem `manifest: remove backup YYYY-MM-DD (rotacao)`
---

## ✅ Validação

Sintaxe JSON
```
jq . images/backups.json
# Se reformatar sem erro: válido
```

Schema esperado
```
# Verifica se todos os backups têm os campos obrigatórios (schema 1.1):
jq -e '.backups | all(has("date") and has("file") and has("md5_file") and has("md5") and has("gdrive_id") and has("gdrive_md5_id"))' images/backups.json
# Saída esperada: true
```

Listar todas as datas
```
jq -r '.backups[].date' images/backups.json
```

Buscar entrada específica
```
jq '.backups[] | select(.date == "2026-06-18")' images/backups.json
```
---

## 🔄 Migrações futuras de schema

O campo `schema_version` permite evolução sem quebrar consumidores antigos:
| Versão | Mudanças |
| --- | --- |
| 1.0 | Schema inicial (filename, size, kernel) |
| 1.1 | Renomeia filename→file, size→size_human; adiciona md5_file e os (atual) |
| 2.0 | futuro: suporte a múltiplos mirrors (não só Drive) |

Scripts devem checar `schema_version` antes de processar e avisar se for desconhecida.
---

## 📋 Template para nova entrada

Copie e ajuste:
```json
{
  "date": "YYYY-MM-DD",
  "file": "firefly-backup-YYYYMMDD-HHMM.img.gz",
  "md5_file": "firefly-backup-YYYYMMDD-HHMM.img.gz.md5",
  "size_human": "?G",
  "size_bytes": 0,
  "md5": "________________________________",
  "gdrive_id": "________________________________",
  "gdrive_md5_id": "________________________________",
  "host": "firefly (?)",
  "os": "?",
  "kernel": "?",
  "notes": "?"
}
```

Comandos para preencher (rode na placa de origem):
```bash
cd images/

echo "file:        $(basename firefly-backup-*.img.gz)"
echo "md5_file:    $(basename firefly-backup-*.img.gz).md5"
echo "size_human:  $(du -h firefly-backup-*.img.gz | cut -f1)"
echo "size_bytes:  $(stat -c%s firefly-backup-*.img.gz)"
echo "md5:         $(md5sum firefly-backup-*.img.gz | cut -d' ' -f1)"
echo "os:          $(lsb_release -ds 2>/dev/null || grep PRETTY_NAME /etc/os-release | cut -d'\"' -f2)"
echo "kernel:      $(uname -r)"
```
---

🔗 Relacionados
- ☁️ Como publicar (passo a passo) [blocked]
- 📥 Como scripts consomem o manifest [blocked]
---
