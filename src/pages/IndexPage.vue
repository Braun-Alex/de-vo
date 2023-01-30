<template>
  <q-page class="row items-center justify-evenly">
    <q-btn @click="retrievePolls()" no-caps>
      Retrieve polls
    </q-btn>
    <q-list bordered separator>
      <q-item v-for="poll in allPolls" :key="poll.whenCreated" clickable v-ripple>
        <q-item-section>{{ poll.title }}</q-item-section>
        <q-item-section>{{ poll.question }}</q-item-section>
        <q-item-section>{{ poll.proposals.join(', ') }}</q-item-section>
        <q-item-section>{{ poll.author }}</q-item-section>
        <q-item-section>{{ poll.whenCreated }}</q-item-section>
        <q-item-section>{{ poll.duration }}</q-item-section>
      </q-item>
    </q-list>
  </q-page>
</template>

<script setup lang="ts">
import { ref, inject, Ref, watch } from 'vue'
import { useQuasar } from 'quasar'
import { ethers } from 'ethers'
import { abi } from 'src/Ballot.json'

interface Poll {
  title: string,
  question: string,
  proposals: string[],
  author: string,
  whenCreated: Date,
  duration: number
}

const $q = useQuasar()
const contractAddress = process.env.VUE_APP_BALLOT_CONTRACT
const allPolls = ref<Poll[]>([])

const contractMutated: Ref<boolean> = inject('contractMutated') as Ref<boolean>

watch(contractMutated, retrievePolls)

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
    try {
      const data = await contract.getAllPolls()
      data.forEach((poll: any) => {
        allPolls.value.push({
          title: poll.title,
          question: poll.question,
          proposals: poll.proposals,
          author: poll.author,
          whenCreated: new Date(poll.whenCreated * 1000),
          duration: poll.duration
        })
      })
    } catch (error: any) {
      $q.notify({
        type: 'negative',
        message: error.message
      })
    }
  }
}
</script>
