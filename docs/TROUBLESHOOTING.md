# 🔧 Troubleshooting

Catálogo de problemas comuns e suas soluções, organizados por área.

---

## 📑 Índice

- [Instalação / Dependências](#instalacao)
- [Download (gdown / Drive)](#download)
- [MD5 mismatch](#md5-mismatch)
- [Clonagem SD → eMMC](#clonagem)
- [Backup](#backup)
- [Restauração](#restauracao)
- [Boot fails after restore](#boot-fails-after-restore)
- [Git / Repositório](#git)

---

## <a id="instalacao"></a>📦 Instalação / Dependências

### `gdown: command not found`

O `pipx` instala em `~/.local/bin`, que precisa estar no `PATH`:

```bash
pipx ensurepath
source ~/.bashrc   # ou reabra o terminal
gdown --version
```

### `pipx: command not found` (sistemas antigos)

Em Debian/Ubuntu antigos:

```bash
sudo apt install python3-pip python3-venv
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```

### `jq: command not found`

```bash
sudo apt install -y jq
# Ou em sistemas RH:
sudo dnf install -y jq
```

---

## <a id="download"></a>📥 Download (gdown / Drive)

### `gdown: error: unrecognized arguments: --fuzzy`

Versão antiga do `gdown`. Atualize:

```bash
pipx install --force gdown
gdown --version   # confirme >= 6.0.0
```

> Os scripts deste repo já são compatíveis com `gdown 6.x` (que extrai ID automaticamente).

### `Permission denied` / "You need access"

O arquivo no Drive não está realmente público:

1. Abra `https://drive.google.com/file/d/<ID>/view` em **aba anônima**
2. Se pedir login: o compartilhamento NÃO está como "Qualquer pessoa com o link"
3. Volte no Drive → botão direito no arquivo → Compartilhar → ajuste

### `Cannot retrieve the public link`

Costuma ocorrer com arquivos > 100 MB que disparam aviso de antivírus do Drive. O script trata via `--continue` e prompt automático, mas se persistir:

```bash
# Force redownload limpando parcial:
rm /tmp/firefly-backup-*.img.gz*
./scripts/07-download-backup.sh <data> /tmp
```

### Download trava em 99%

Costuma ser limite de cota do Drive (muitas tentativas). Aguarde **24h** ou tente de outra rede/conta.

---

## <a id="md5-mismatch"></a>🔐 MD5 mismatch

### `MD5 manifest FAIL`

Hash do arquivo baixado **não** bate com o do `backups.json`.

**Diagnóstico:**

```bash
# Hash real do arquivo baixado:
md5sum /tmp/firefly-backup-*.img.gz

# Hash esperado (manifest):
jq -r '.backups[] | select(.date=="2026-06-18") | .md5' images/backups.json

# Hash do .md5 companheiro:
cat /tmp/firefly-backup-*.img.gz.md5
```

**Possíveis causas:**

1. **Download corrompido** — re-baixe (`rm` + script de novo)
2. **Arquivo no Drive foi substituído** sem atualizar manifest — reporte ao mantenedor
3. **Manifest desatualizado** — `git pull` para puxar correções

### `MD5 file FAIL` mas `MD5 manifest OK`

O arquivo `.md5` no Drive está com hash antigo/errado, mas a imagem está íntegra (manifest confirma). **Use a imagem normalmente** e reporte para o mantenedor regenerar o `.md5`.

---

## <a id="clonagem"></a>🧬 Clonagem SD → eMMC

### Script aborta com "partição não encontrada"

O layout do seu SD difere do esperado. Inspecione manualmente:

```bash
sudo fdisk -l /dev/mmcblk1
sudo blkid
```

Ajuste as variáveis de identificação no início de `01-validate-raw-partitions.sh` se necessário.

### `rsync: write failed: No space left on device`

eMMC é menor que o SD. Limpe antes de clonar:

```bash
sudo apt clean
sudo journalctl --vacuum-time=1d
rm -rf ~/.cache/*
```

Veja uso real:

```bash
df -h /
du -sh /var /usr /home /opt
```

### UUIDs duplicados após clone

```bash
sudo blkid /dev/mmcblk0p* /dev/mmcblk1p*
# Se houver duplicação, regenere na eMMC:
sudo tune2fs -U random /dev/mmcblk0p?
```

---

## <a id="backup"></a>💾 Backup

### Backup parece pequeno demais

Se uma imagem de 16 GB virou 200 MB comprimida, **algo deu errado**:

- O `dd` pode ter abortado cedo
- O dispositivo pode estar montado e bloqueando leitura completa

**Validação:**

```bash
gzip -l images/firefly-backup-*.img.gz
# A coluna "uncompressed" deve bater com o tamanho da eMMC
```

### "Resource busy" durante backup

Você está tentando ler o dispositivo onde o sistema atual está rodando. **Faça backup do dispositivo INATIVO**:

- Rodando do SD → backup da eMMC
- Rodando da eMMC → backup do SD (se houver)

---

## <a id="restauracao"></a>♻️ Restauração

### "Device not found" / `/dev/mmcblkX` inexistente

```bash
lsblk          # confirme nome real
sudo dmesg | tail -20   # veja se foi detectado
```

### Restauração trava em 100%

Normal — o `sync` no final pode levar 1-3 min para flush completo do buffer. **Não interrompa.**

---

## <a id="boot-fails-after-restore"></a>🚫 Boot fails after restore

### Sintoma: tela preta, LED pisca, mas não dá boot

**Diagnóstico em 4 passos:**

1. **Reinsira o SD original** para ter sistema funcional
2. **Monte a partição boot da imagem restaurada:**
   ```bash
   sudo mkdir -p /mnt/restored-boot
   sudo mount /dev/mmcblk0p? /mnt/restored-boot   # ajuste número
   ls /mnt/restored-boot
   ```
3. **Confirme presença de:**
   - `extlinux/extlinux.conf`
   - `Image` ou `vmlinuz-*`
   - `*.dtb` (device tree)
4. **Verifique `extlinux.conf`:**
   ```bash
   cat /mnt/restored-boot/extlinux/extlinux.conf
   # root=UUID=... deve apontar para a partição rootfs CORRETA
   sudo blkid /dev/mmcblk0p?   # compare UUIDs
   ```

### Sintoma: "Cannot find rootfs"

UUID em `extlinux.conf` ou `/etc/fstab` não bate com UUID real da partição. Corrija:

```bash
sudo blkid /dev/mmcblk0p?   # anote UUID real
sudo nano /mnt/restored-boot/extlinux/extlinux.conf
# Ajuste root=UUID=<uuid-real>
```

---

## <a id="git"></a>🐙 Git / Repositório

### `warning: CRLF will be replaced by LF`

**Não é erro.** O `.gitattributes` está normalizando line endings (CRLF do Windows → LF do Unix). Esperado e desejado para scripts `.sh`.

### `*.img.gz` aparecendo no `git status`

O `.gitignore` deveria bloquear. Confira:

```bash
cat .gitignore | grep img
# Esperado: images/*.img.gz
```

Se já foi adicionado antes:

```bash
git rm --cached images/*.img.gz
git commit -m "fix: remove imagens do tracking"
```

### `Permission denied (publickey)` no push

Configure SSH ou use HTTPS com token:

```bash
# Via HTTPS + Personal Access Token:
git remote set-url origin https://github.com/Jean-DrEaD/firefly-rk3399.git
git push   # usa o token salvo no Credential Manager
```

---

## 🆘 Não achei meu problema

1. Procure issues abertas/fechadas no [GitHub](https://github.com/Jean-DrEaD/firefly-rk3399/issues)
2. Abra nova issue com:
   - Distro + versão (`lsb_release -a`)
   - Versão do `gdown` (`gdown --version`)
   - Comando exato + saída completa
   - Conteúdo de `images/backups.json` (se relacionado a manifest)

---

## 🔗 Relacionados

- 📦 [Voltar para INSTALL](INSTALL.md)
- 📥 [Voltar para DOWNLOAD](DOWNLOAD.md)
