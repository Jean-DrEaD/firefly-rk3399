# ♻️ Restauração de imagem

Como **gravar uma imagem `.img.gz`** em um SD card ou eMMC, recriando o sistema completo.

---

## ⚠️ ATENÇÃO

> 🚨 **Esse processo apaga TUDO no dispositivo de destino.** Não há confirmação visual além do prompt do script. Confirme **3 vezes** o caminho `/dev/...` antes de prosseguir.

---

## 🎯 Quando usar

- Aplicar um backup baixado em uma placa nova
- Restaurar após corrupção/falha
- Replicar setup idêntico em múltiplas placas

---

## 📋 Pré-requisitos

- Imagem `.img.gz` em mãos (gerada localmente ou baixada — veja [`DOWNLOAD.md`](DOWNLOAD.md))
- Dispositivo destino conectado (SD via leitor USB, ou eMMC via boot pelo SD)
- Acesso root
- Pacotes: `gzip`, `dd`, `coreutils`

---

## 🔍 Identificar o dispositivo destino

**Esse é o passo mais crítico.** Errar aqui = perder dados de outro disco.

### Método 1: comparar `lsblk` antes/depois

```bash
# 1. ANTES de plugar o destino:
lsblk

# 2. Plugue o SD/USB com o cartão destino

# 3. DEPOIS:
lsblk

# O dispositivo NOVO que apareceu é o seu destino
```

### Método 2: `dmesg` em tempo real

```bash
sudo dmesg -w
# Plugue o dispositivo
# Observe a última linha: [sdX] ou [mmcblkX]
```

### Padrões típicos

| Plataforma | Dispositivo destino |
|-----------|---------------------|
| Firefly bootando do SD, gravando na eMMC | `/dev/mmcblk0` |
| Firefly bootando da eMMC, gravando no SD | `/dev/mmcblk1` |
| PC com leitor USB de SD | `/dev/sdb` ou `/dev/sdc` |
| Raspberry Pi com SD em adaptador USB | `/dev/sda` |

> ⚠️ **NUNCA use o sufixo de partição** (`p1`, `p2`, `1`, `2`). O script grava no **dispositivo inteiro**, não em uma partição.

---

## 🚀 Restauração

### Sintaxe

```bash
sudo ./scripts/99-restore-image.sh <caminho-imagem.img.gz> <dispositivo>
```

### Exemplo

```bash
sudo ./scripts/99-restore-image.sh /tmp/firefly-backup-20260430.img.gz /dev/mmcblk1
```

**Fluxo:**

1. ✅ Valida que a imagem existe e é leg vel
2. ✅ Valida que o destino é dispositivo de bloco (não arquivo, não partição)
3. ⚠️ Mostra resumo (origem, destino, tamanho do destino)
4. ⚠️ **Pede confirmação duas vezes** (responda `s` ou `sim` em minúsculas)
5. 🔓 Desmonta partições do destino se montadas
6. 📥 Descomprime + grava com `gunzip -c | dd`
7. 🔄 Sincroniza buffers (`sync`)
8. 🔍 Recarrega tabela de partições (`partprobe`)

**Saída esperada:**

```
[INFO] 🔍 Imagem: /tmp/firefly-backup-20260430.img.gz (3.2G)
[INFO] 🎯 Destino: /dev/mmcblk1 (15.6G, MMC)
[WARN] ⚠️  ATENCAO: TODOS os dados em /dev/mmcblk1 serao APAGADOS!

Tem CERTEZA que deseja restaurar? [s/N]: s
Última chance — confirmar novamente? [s/N]: s

[INFO] 🔓 Desmontando particoes do destino...
[INFO] 📥 Gravando imagem (descompactando)...
15.6GiB 0:38:42 [6.88MiB/s] [====================>] 100%
[INFO] 🔄 Sincronizando buffers...
[INFO] 🔍 Recarregando tabela de particoes...
[INFO] ✅ Restauracao concluida!

💡 Proximos passos:
   - Remova o dispositivo com seguranca
   - Insira/reboote na placa de destino
```

---

## ⏱️ Tempo típico

| Tamanho da imagem (descomprimida) | Tempo |
|----------------------------------|-------|
| 8 GB | ~20 min |
| 16 GB | ~40 min |
| 32 GB | ~80 min |

> Velocidade depende principalmente da escrita do destino (eMMC > SD UHS-I > SD comum).

---

## 🔬 Validação pós-restauração

### Verificar tabela de partições

```bash
sudo fdisk -l /dev/mmcblk1
# Deve mostrar partições boot, rootfs, userdata
```

### Montar e inspecionar rootfs

```bash
sudo mkdir -p /mnt/restored
sudo mount /dev/mmcblk1p? /mnt/restored   # ajuste o número da partição rootfs
ls /mnt/restored
# Deve listar: bin, boot, etc, home, root, usr, var...
sudo umount /mnt/restored
```

### Boot test

1. Insira o dispositivo na placa destino
2. Religue
3. Sistema deve subir normalmente

---

## 🐛 Problemas comuns

### "Device or resource busy"

Alguma partição do destino está montada. Force desmontar:

```bash
sudo umount /dev/mmcblk1*
# Ou:
sudo umount -l /dev/mmcblk1p?   # lazy unmount
```

### "No space left on device" durante gravação

A imagem descomprimida é **maior** que o destino:

```bash
# Tamanho descomprimido da imagem:
gzip -l firefly-backup-*.img.gz

# Tamanho do destino:
lsblk -b /dev/mmcblk1 | head -2
```

Solução: use um destino igual ou maior que a imagem original.

### Boot falha após restauração

Veja [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md#boot-fails-after-restore).

---

## 🔗 Próximos passos

- 🔧 [Troubleshooting completo](TROUBLESHOOTING.md)
- 💾 [Gerar seu próprio backup](BACKUP.md)
