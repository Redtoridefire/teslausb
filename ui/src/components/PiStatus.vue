<template>
    <div class="pi-status" v-if="piStatus">
        <div class="uptime-row">
            <span>🟢 {{ piStatus.uptime }}</span>
            <span>⚡️ {{ piStatus.cpuVolt }}</span>
            <span>🔥 {{ piStatus.cpuTemp }}</span>
            <span>💪 {{ piStatus.loadAverage }}</span>
        </div>
        <VeuiProgress class="size-indicator" :max="piStatus.totalSize" :value="usedSize" desc>
            <span>{{ bytes(usedSize) }} / {{ bytes(piStatus.totalSize) }}</span>
            <span class="left-space">({{ piStatus.snapCount }} snapshot{{ piStatus.snapCount > 1 ? 's' : '' }})</span>
        </VeuiProgress>
    </div>
</template>

<script>
import {getPiStatus} from '../apis/device';
import bytes from 'bytes';

export default {
    data() {
        return {
            piStatus: undefined
        }
    },
    computed: {
        usedSize() {
            const {freeSize, totalSize} = this.piStatus;
            return totalSize - freeSize;
        }
    },
    methods: {
        bytes(val) {
            return bytes(val, {decimalPlaces: 0});
        },
        async refresh() {
            try {
                this.piStatus = await getPiStatus();
            } catch {}
        }
    },
    mounted() {
        this.refresh();
        this.timer = setInterval(() => this.refresh(), 10000);
    },
    beforeDestroy() {
        clearInterval(this.timer);
    }
}
</script>

<style lang="less" scoped>
@import "~less-plugin-dls/tokens/index.less";

.pi-status {
    padding: 1em 20px;
    border: 1px solid @dls-line-color-2;
    border-radius: @dls-border-radius-2;
    box-shadow: @dls-shadow-2;
    font-family: monospace;
}

.size-indicator {
    margin-top: 10px;
    flex-wrap: wrap;
}
.left-space {
    margin-left: 1em;
}

.uptime-row {
    margin-bottom: 5px;
    & > span::after {
        content: ",";
        color: gray;
    }
    & > span:last-child::after {
        content: unset;
    }

    & > span {
        display: inline-block;
        margin-right: 1.2em;
    }
}
</style>
