const express = require('express');
const esptool = require('esptool-js');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3000;

app.use(express.static('public'));

app.post('/flash', async (req, res) => {
    try {
        const device = await esptool.connect();
        console.log("Connected to ESP32");

        // Pre-included binaries and their respective offsets
        const filesToFlash = [
            { file: path.join(__dirname, 'uploads', 'bootloader.bin'), offset: 0x1000 },
            { file: path.join(__dirname, 'uploads', 'partitions.bin'), offset: 0x8000 },
            { file: path.join(__dirname, 'uploads', 'boot_app0.bin'), offset: 0xe000 },
            { file: path.join(__dirname, 'uploads', 'firmware.bin'), offset: 0x10000 },
            { file: path.join(__dirname, 'uploads', 'spiffs.bin'), offset: 0x290000 }
        ];

        for (const { file, offset } of filesToFlash) {
            const binary = fs.readFileSync(file);
            console.log(`Flashing ${file} to offset 0x${offset.toString(16)}`);
            await device.flashData(offset, binary);
        }

        await device.disconnect();
        console.log("Flashing complete");

        res.send("ESP32 flashed successfully!");
    } catch (err) {
        console.error(err);
        res.status(500).send("Error flashing ESP32");
    }
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
