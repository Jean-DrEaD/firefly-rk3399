# 💾 Backup completo da eMMC

Geração de imagem `.img.gz` da eMMC inteira para backup ou replicação em outras placas.

---

## 🎯 Quando usar

- Após clonar SD → eMMC e validar funcionamento
- Antes de fazer mudanças significativas no sistema
- Para distribuir um setup pronto para outras placas idênticas
- Snapshot de segurança periódico

---

## 📋 Pré-requisitos

- Sistema rodando da eMMC (não do SD!)
- Espaço livre suficiente em destino externo (USB, NFS, etc.)
- `gzip`, `pv`, `coreutils` instalados

**Por quê rodar da eMMC?** Se você está rodando do SD e tenta gerar imagem da eMMC montada, o resultado pode ficar inconsistente. **Sempre faça backup do dispositivo que NÃO está sendo usado como root.**

---

## 🚀 Uso

### Comando padrão

```bash
cd ~/firefly-rk3399
sudo ./scripts/05-backup-emmc.sh
```

**O que faz:**

1. Detecta o dispositivo eMMC
2. Gera nome com data: `firefly-backup-YYYYMMDD.img.gz`
3. Lê dispositivo bloco-a-bloco com `dd`
4. Pipa para `gzip -1` (otimizado para velocidade)
5. Calcula MD5 ao final
6. Salva `.md5` companheiro e `.meta` com metadados

**Saída esperada:**

```
[INFO] eMMC detectado: /dev/mmcblk0
[INFO] Origem:  /dev/mmcblk0
[INFO] Destino: /userdata/firefly-backup-20260619-1950.img.gz
[WARN] Garanta espaço livre suficiente em /userdata
[INFO] Gerando imagem comprimida (gzip -1, otimizado para velocidade)...
16384+0 records in/out ... (dd progress)
[ OK ] Backup concluído!
─────────────────────────────────────────
file:       firefly-backup-20260619-1950.img.gz
size:       3.9G
md5:        ac7349eab68fe2879ba58eb68400ce9d
elapsed:    2340s
─────────────────────────────────────────
```

---

## 📂 Arquivos gerados

Em `/userdata/` (padrão) ou no diretório passado como argumento:

| Arquivo | Tamanho típico | Descrição |
|---------|---------------|-----------|
| `firefly-backup-YYYYMMDD.img.gz` | 2-4 GB | Imagem comprimida da eMMC |
| `firefly-backup-YYYYMMDD.img.gz.md5` | < 1 KB | Hash MD5 companheiro |

> 📝 As imagens `.img.gz` são **ignoradas pelo Git** (`.gitignore`). A distribuição é via Google Drive — veja [`DISTRIBUTION.md`](DISTRIBUTION.md).

---

## ⚙️ Customizações

### Alterar destino

Passe o caminho completo como primeiro argumento:

```bash
sudo ./scripts/05-backup-emmc.sh /mnt/usb-externo/meu-firefly.img.gz
```

Se omitido, o padrão é `/userdata/firefly-backup-YYYYMMDD-HHMM.img.gz`.

### Compressão máxima (arquivo menor)

O padrão é `gzip -1` (velocidade). Para priorizar tamanho menor, edite o script:

```bash
# Antes:  gzip -1
# Depois: gzip -9   (arquivo menor, mas ~10x mais lento)
```

---

## ⏱️ Tempo e tamanho típicos

| eMMC | Tempo backup (gzip -1) | Tamanho final |
|------|------------------------|---------------|
| 8 GB | ~25 min | 1.5-2.5 GB |
| 16 GB | ~45 min | 2.5-4 GB |
| 32 GB | ~90 min | 4-7 GB |

> Valores variam conforme conteúdo (sistema vazio comprime mais; dados aleatórios comprimem pouco).

---

## 🔍 Validação imediata

Após gerar, valide o MD5:

```bash
cd images/
md5sum -c firefly-backup-20260619-1950.img.gz.md5
# Esperado: firefly-backup-20260619-1950.img.gz: OK
```

---

## 🔗 Próximos passos

- ☁️ [Publicar no Google Drive](DISTRIBUTION.md)
- ♻️ [Restaurar em outra placa](RESTORE.md)
