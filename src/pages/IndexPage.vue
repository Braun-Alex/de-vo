<template>
  <q-page class="row items-center justify-evenly">
    <example-component
      title="Контент"
      active
      :todos="todos"
      :meta="meta"
    ></example-component>
  </q-page>
</template>

<script setup lang="ts">
import { Todo, Meta } from 'components/models'
import ExampleComponent from 'components/ExampleComponent.vue'
import { ref } from 'vue'

const todos = ref<Todo[]>([
  {
    id: 1,
    content: 'Один'
  },
  {
    id: 2,
    content: 'Два'
  },
  {
    id: 3,
    content: 'Три'
  },
  {
    id: 4,
    content: 'Чотири'
  },
  {
    id: 5,
    content: 'П\'ять'
  }
])
const meta = ref<Meta>({
  totalCount: 1200
})
</script>
