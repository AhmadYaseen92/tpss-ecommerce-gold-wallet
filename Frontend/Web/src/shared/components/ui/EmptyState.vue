<script setup lang="ts">defineProps<{ message?: string }>();</script>
<template><div class="ui-state">{{ message ?? 'No records found.' }}</div></template>
