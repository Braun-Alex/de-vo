<template>
  <div class="q-pa-md q-gutter-md">
    <q-btn @click="retrievePolls()" no-caps>
      Retrieve polls
    </q-btn>
    <q-list bordered class="rounded-borders">
      <q-item-label header>Коли створено</q-item-label>

      <q-item v-for="poll in allPolls" :key="poll.whenCreated">
        <q-item-section avatar top>
          <q-icon name="account_tree" color="black" />
        </q-item-section>

        <q-item-section top class="col-2 gt-sm">
          <q-item-label class="q-mt-sm">
            {{ String(poll.author.slice(0, 5) + '...' + poll.author.slice(-4)) }}
          </q-item-label>
        </q-item-section>

        <q-item-section top>
          <q-item-label lines="1">
            <span class="text-weight-medium">
              {{ poll.title }}
            </span>
          </q-item-label>
          <q-item-label caption lines="1">
            {{ poll.question }}
          </q-item-label>
          <q-item-label lines="1" class="q-mt-xs text-body2 text-weight-bold text-primary">
            <span>{{ poll.duration }}</span>
          </q-item-label>
        </q-item-section>

        <q-item-section top side>
          <div class="text-grey-8 q-gutter-xs">
            <q-btn round icon="ballot">
              <q-tooltip>Проголосувати</q-tooltip>
            </q-btn>
          </div>
        </q-item-section>
      </q-item>

    </q-list>
  </div>
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
