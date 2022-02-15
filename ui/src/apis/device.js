import {cacheBustinguURL, delay, callCgi} from './helper';

export function triggerArchiveSync() {
    return callCgi('/cgi-bin/trigger_sync.sh', 'trigger sync');
}

export async function reboot() {
    await callCgi('/cgi-bin/reboot.sh', 'reboot');
    await delay(5000);
    while (!(await checkAlive())) {
        await delay(1000);
    }
}

export async function getPiStatus() {
    const result = await callCgi('/cgi-bin/status.sh', 'getPiStatus');
    const [uptime, cpuVolt, cpuTemp, totalSize, freeSize, snapCount] = result.split('\n');
    return {
        freeSize: parseInt(freeSize, 10),
        totalSize: parseInt(totalSize, 10),
        snapCount: parseInt(snapCount, 10),
        cpuVolt: cpuVolt.substring(cpuVolt.indexOf('=') + 1),
        cpuTemp: cpuTemp.substring(cpuTemp.indexOf('=') + 1),
        ...parseUptime(uptime)
    };
}

function parseUptime(str) {
    let [uptime, , loadAverage] = str.split('up')[1].trim().split(',  ').map(item => item.trim());
    uptime = uptime.replace(',', '');
    loadAverage = loadAverage.split(':')[1].trim();
    return {
        uptime,
        loadAverage
    };
}

async function checkAlive() {
    const url = cacheBustinguURL('index.html');
    const response = await fetch(url, {method: 'GET'});
    return response.ok;
}
