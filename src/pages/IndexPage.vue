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
import { ethers } from 'ethers'
import { abi } from 'Ballot.json'

interface Poll {
  title: string,
  question: string,
  proposals: string[],
  author: string,
  whenCreated: Date,
  duration: number
}

const contractAddress = process.env.VUE_APP_BALLOT_CONTRACT
const allPolls = ref<Poll[]>([])

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

async function retrievePolls () {
  allPolls.value = []
  // @ts-expect-error Window.ethers not TS
  if (typeof window.ethereum !== 'undefined') {
    // @ts-expect-error Window.ethers not TS
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const contract = new ethers.Contract(
      contractAddress as string,
      abi,
      provider
    )
  }
}
</script>
