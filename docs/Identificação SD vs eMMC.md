### `Identificação SD vs eMMC`

for dev in mmcblk0 mmcblk2; do
    type=$(cat /sys/block/$dev/device/type 2>/dev/null)
    name=$(cat /sys/block/$dev/device/name 2>/dev/null)
    echo "/dev/$dev → tipo=$type nome=$name"
done

`Saída esperada no Firefly-RK3399:`
/dev/mmcblk0 → tipo=MMC  nome=AJTD4R   ← eMMC interno
/dev/mmcblk2 → tipo=SD   nome=SDABC    ← SD card
