# 📦 Instalação e pré-requisitos

Este projeto tem **3 cenários de uso** com dependências diferentes. Identifique o seu antes de instalar.

---

## 🎯 Cenário 1: Apenas baixar backups prontos

Você tem uma placa nova/zerada e quer **restaurar** um backup já publicado.

### Pacotes necessários

```bash
sudo apt update
sudo apt install -y jq pipx coreutils git
pipx ensurepath
```

Reabra o terminal (ou `source ~/.bashrc`) e instale o `gdown`:

```bash
pipx install gdown
gdown --version   # deve ser >= 6.0.0
```

### Validação

```bash
command -v jq      && echo "jq OK"
command -v gdown   && echo "gdown OK"
command -v md5sum  && echo "md5sum OK"
```

---

## 🎯 Cenário 2: Clonar SD → eMMC (na placa Firefly)

Você tem um SD funcional e quer migrar para a eMMC interna.

```bash
sudo apt update
sudo apt install -y rsync parted util-linux coreutils gzip pv
```

> 💡 A maioria dessas ferramentas já vem instalada no Ubuntu BSP do Firefly.

---

## 🎯 Cenário 3: Gerar e publicar backups

Inclui tudo do Cenário 2 +:

```bash
sudo apt install -y gzip pv
```

Para upload no Drive, usa-se a interface web do Google Drive (não há CLI obrigatória).

---

## ⚠️ Notas importantes

### gdown 6.x

A partir da versão **6.0.0** (abril/2026), o `gdown`:

- ❌ Removeu a flag `--fuzzy`
- ❌ Removeu a flag `--id`
- ✅ Faz extração automática de ID em qualquer URL/ID do Drive
- ✅ Requer Python >= 3.10

Os scripts deste repo **já estão adaptados**. Se você tem `gdown < 6`, atualize:

```bash
pipx install --force gdown
```

### Permissões

Scripts que mexem em dispositivos de bloco (`/dev/mmcblk*`, `/dev/sd*`) precisam de **root**:

- `01-validate-raw-partitions.sh`
- `02-clone-boot.sh`, `03-clone-rootfs.sh`, `04-clone-userdata.sh`
- `05-backup-emmc.sh`
- `99-restore-image.sh`

Scripts de **leitura/download** rodam como usuário comum:

- `06-list-backups.sh`
- `07-download-backup.sh`

---

## 🔗 Próximos passos

- 🧬 [Clonar SD → eMMC](CLONING.md)
- 📥 [Baixar backup pronto](DOWNLOAD.md)
- 🔧 [Troubleshooting](TROUBLESHOOTING.md)
