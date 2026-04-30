# 🧬 Clonagem SD → eMMC

Este guia documenta o processo de **migrar um sistema funcional do SD card para a eMMC interna** de placas Firefly RK3399, usando os scripts `01` a `04`.

---

## 🎯 Quando usar

- Você tem um SD card com sistema instalado e configurado
- Quer mover tudo para a eMMC (mais rápida, mais durável)
- Quer manter UUIDs, configurações e dados intactos

---

## 📋 Pré-requisitos

- Placa Firefly RK3399 (ou similar) com eMMC presente
- SD card bootável com sistema funcional
- Pacotes instalados (veja [`INSTALL.md`](INSTALL.md) — Cenário 2)
- Acesso root (sudo)

---

## 🚀 Fluxo completo

### 1. Boot pelo SD card

Insira o SD na placa e ligue normalmente. Confirme que está rodando do SD:

```bash
lsblk
# Esperado: rootfs montado em /dev/mmcblk1p? (SD)
#           /dev/mmcblk0 presente mas não montado (eMMC)
```

> ⚠️ A nomenclatura pode variar (`mmcblk0` vs `mmcblk1`). **Sempre confirme com `lsblk` antes de cada comando.**

---

### 2. Clone o repositório

```bash
cd ~
git clone https://github.com/Jean-DrEaD/firefly-rk3399.git
cd firefly-rk3399
chmod +x scripts/*.sh
```

---

### 3. Valide as partições do SD

```bash
sudo ./scripts/01-validate-raw-partitions.sh
```

**O que faz:**
- Inspeciona a tabela de partições do SD
- Confirma presença de `boot`, `rootfs` e `userdata`
- Valida UUIDs e tipos de filesystem
- Aborta se encontrar inconsistências

**Saída esperada:**

```
[INFO] ✅ Partição boot encontrada (vfat)
[INFO] ✅ Partição rootfs encontrada (ext4)
[INFO] ✅ Partição userdata encontrada (ext4)
[INFO] 🎉 Validação concluída — pronto para clonar.
```

---

### 4. Clone a partição /boot

```bash
sudo ./scripts/02-clone-boot.sh
```

**O que faz:**
- Cria/formata a partição de boot na eMMC
- Copia kernel, dtb, extlinux.conf, uboot script
- Preserva flags de boot e tipo de filesystem

---

### 5. Clone o rootfs

```bash
sudo ./scripts/03-clone-rootfs.sh
```

**O que faz:**
- Formata a partição rootfs na eMMC (ext4)
- Usa `rsync -aHAX` (preserva permissões, hardlinks, ACLs, xattrs)
- Atualiza `/etc/fstab` com os novos UUIDs
- Reescreve `extlinux.conf` apontando para o rootfs da eMMC

**Tempo estimado:** 10-25 min (dependendo do tamanho do sistema).

---

### 6. Clone /userdata

```bash
sudo ./scripts/04-clone-userdata.sh
```

**O que faz:**
- Replica a partição `/userdata` (configs Klipper, perfis, prints)
- Usa `rsync` preservando timestamps e ownership

> 💡 Se você não usa `/userdata`, esse script é opcional.

---

### 7. Reinicie sem o SD

```bash
sudo poweroff
```

1. Aguarde a placa desligar completamente
2. **Remova o SD card**
3. Religue
4. A placa deve dar boot pela eMMC ✅

**Validação pós-boot:**

```bash
lsblk
# Esperado: rootfs montado em /dev/mmcblk0p? (eMMC)

df -h /
# Confirma espaço da eMMC, não do SD
```

---

## 🐛 Problemas comuns

### Boot fica em loop / kernel panic

1. Religue com SD inserido (vai bootar pelo SD de novo)
2. Verifique `/boot/extlinux/extlinux.conf` na eMMC:
   ```bash
   sudo mount /dev/mmcblk0p? /mnt
   cat /mnt/extlinux/extlinux.conf
   ```
3. Confirme que `root=UUID=...` aponta pra partição correta

### Erro "no space left on device" durante rsync

A eMMC pode ser **menor** que o SD. Estratégias:
- Limpe `/var/cache/apt`, `/tmp`, logs antigos antes de clonar
- Use `df -h` no SD para ver uso real
- Se rootfs do SD está com 12 GB e eMMC é 16 GB, deve caber

### UUIDs duplicados

Se ambos (SD e eMMC) ficarem com mesmo UUID após clone, o boot fica imprevisível. Os scripts já regeneram UUID na eMMC, mas confirme:

```bash
sudo blkid /dev/mmcblk0p? /dev/mmcblk1p?
# UUIDs devem ser diferentes
```

Mais soluções em [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md).

---

## 🔗 Próximos passos

- 💾 [Gerar backup da eMMC clonada](BACKUP.md)
- ☁️ [Distribuir o backup via Drive](DISTRIBUTION.md)
