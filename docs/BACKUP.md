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
4. Pipa para `gzip -9` (compressão máxima)
5. Mostra progresso com `pv`
6. Calcula MD5 ao final
7. Salva `.md5` companheiro

**Saída esperada:**

```
[INFO] 🔍 Detectando dispositivo eMMC...
[INFO]    Origem: /dev/mmcblk0 (15.6 GB)
[INFO] 📦 Gerando imagem comprimida...
[INFO]    Destino: images/firefly-backup-20260430.img.gz
15.6GiB 0:42:18 [6.30MiB/s] [====================>] 100%
[INFO] 🔐 Calculando MD5...
[INFO] ✅ MD5: 1ab974d2268be859fdcacaadca9b65cf
[INFO] 💾 Tamanho final: 3.2 GB (taxa de compressao: 4.9x)
[INFO] 🎉 Backup concluido!
```

---

## 📂 Arquivos gerados

Em `images/`:

| Arquivo | Tamanho típico | Descrição |
|---------|---------------|-----------|
| `firefly-backup-YYYYMMDD.img.gz` | 2-4 GB | Imagem comprimida da eMMC |
| `firefly-backup-YYYYMMDD.img.gz.md5` | < 1 KB | Hash MD5 companheiro |

> 📝 Ambos são **ignorados pelo Git** (`.gitignore`). A distribuição é via Google Drive — veja [`DISTRIBUTION.md`](DISTRIBUTION.md).

---

## ⚙️ Customizações

### Alterar destino

Edite as variáveis no início do `05-backup-emmc.sh`:

```bash
OUT_DIR="${OUT_DIR:-./images}"
PREFIX="${PREFIX:-firefly-backup}"
```

Ou exporte antes de rodar:

```bash
sudo OUT_DIR=/mnt/usb-externo PREFIX=meu-firefly ./scripts/05-backup-emmc.sh
```

### Compressão mais rápida (menor compressão)

Se você prioriza velocidade sobre tamanho, troque no script:

```bash
# Antes:  gzip -9
# Depois: gzip -1   (10x mais rápido, ~20% maior)
```

---

## ⏱️ Tempo e tamanho típicos

| eMMC | Tempo backup (gzip -9) | Tamanho final |
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
md5sum -c firefly-backup-20260430.img.gz.md5
# Esperado: firefly-backup-20260430.img.gz: OK
```

---

## 🔗 Próximos passos

- ☁️ [Publicar no Google Drive](DISTRIBUTION.md)
- ♻️ [Restaurar em outra placa](RESTORE.md)
