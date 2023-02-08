<template>
  <div class="q-pa-md">
  <q-tabs
    v-model="tip"
    indicator-color="transparent"
    active-color="white"
    class="bg-teal text-grey-5 shadow-2"
  >
    <q-tab name="edit" icon="mail" label="Як проголосовути" no-caps />
    <q-tab name="add_circle" icon="alarm" label="Як створити голосування" no-caps />
  </q-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, Ref } from 'vue'
const tip: Ref<string> = ref<string>('edit')
</script>
